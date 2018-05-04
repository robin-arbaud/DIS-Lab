-- AUTHORS
-- Dinka Milovancev
-- Benedikt Tutzer
-- April 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_tx_pkg.all;

entity rng is
	generic (

		--Width of the generated number
		RNG_WIDTH : integer := 128;

		--Width of the parity filter to balance uneven duty cycles
		PARITY_FILTER_WIDTH : integer :=4;

		--How many clocks each digit is illuminated
		DISPLAY_REFRESH_DIVIDER : integer :=100000;

		--Baud rate of the UART interface
		BAUDRATE_UART : integer := 115200;

		--Fast system clock frequency, to calculate Baud rate
		CLK_FREQ : integer := 100000000;

		--How many values should be sent in test-mode
		NUM_TEST_OUTPUT : integer := 10000
	);
	port (
		--high for productive mode, low for test mode
		op_mode		: in	std_logic;

		--high active reset signal
		reset		: in	std_logic;

		--connect to button to request a random number in productive
		--mode. Releasing the button generates the request
		gen_num_req	: in	std_logic;

		--fast system clock
		clk_h		: in	std_logic;

		--slow external oscillator
		clk_l		: in	std_logic;
		clk_l_cpy	: out	std_logic;
		clk_l_inv	: out	std_logic;
		clk_l_measure	: out	std_logic;

		--uart tx line
		uart_tx_out	: out	std_logic;

		--data for the current digit
		display_data	: out std_logic_vector(7 downto 0);
		--select digit to illuminate
		display_select	: out std_logic_vector(8 downto 1)
	);
end rng;

architecture behav of rng is

	--buffers PARITY_FILTER_WIDTH samples of the high clock
	signal	buf : std_logic_vector(PARITY_FILTER_WIDTH downto 1);
	--parity over buf
	signal	buf_parity : std_logic := '0';
	--how many values were buffered
	signal	buf_cntr : integer range 0 to PARITY_FILTER_WIDTH;
	--how many values were stored in the ram
	signal	ram_addr : integer range 1 to RNG_WIDTH;
	--stores valid values (the parity of PARITY_FILTER_WIDTH values is
	--stored)
	signal	ram : std_logic_vector(RNG_WIDTH downto 1);

	--the last value the TRNG generated
	signal	current_value : std_logic_vector(RNG_WIDTH-1 downto 0);
	
	--what digit is currently illuminated
	signal	display_num : integer range 1 to 8;
	--the value that is currently displayed
	signal	display_out : std_logic_vector(32 downto 1);
	--the digit that is displayed the next time the display is changed
	signal	next_digit : std_logic_vector(3 downto 0);
	--divides the clock by DISPLAY_REFRESH_DIVIDER
	signal	display_div : integer range 1 to DISPLAY_REFRESH_DIVIDER;

	--high if the TRNG generated a new value in the last cycle of the
	--slow clock
	signal	trng_new : std_logic;
	--high if the TRNG generated a new value before the current cycle of the
	--fast clock. This information is needed to know wether the last value
	--might have already been used or not, since trng_new is only refreshed
	--by a rising edge of the slow clock, but the fast clock can perform
	--multiple cycles before this happens
	signal	trng_old : std_logic;
	--wether the value in current_value is fresh or was already used.
	signal	trng_ready : std_logic;

	--wether the button to request a new value was pushed in the previous
	--cycle. Needed for edge detection, a new value is only generated when
	--the button is realeased to make sure only one value is generated on
	--each push
	signal	gen_num_req_down : std_logic;

	--signals for the UART-tx core.
	signal	uart_send : std_logic;
	signal	uart_data : std_logic_vector(7 downto 0);
	signal	uart_rdy : std_logic;

	--the value that is currently sent over uart
	signal	uart_out : std_logic_vector(RNG_WIDTH-1 downto 0);
	--how many bytes are still to be sent
	signal	uart_cnt : integer range 0 to (RNG_WIDTH+16);

	--counter for the test-mode.
	signal	cnt_values : integer range 0 to NUM_TEST_OUTPUT;

	--xor over std_logic_vector of arbitrary length
	function vector_xor(vec_in: std_logic_vector) return std_logic is
	variable bit_out: std_logic;
	begin
		bit_out := '0';
		for i in vec_in'range loop
			bit_out := bit_out xor vec_in(i);
		end loop;
		return bit_out;
	end;

	--increment that resets to 1 if max_value is reached
	function inc_overflow(value : integer; max_value : integer)
		return integer is
	begin
		if value = max_value then
			return 1;
		else
			return value + 1;
		end if;
	end;

begin

	--needed for the external oscillator
	clk_l_cpy <= clk_l;
	clk_l_inv <= not clk_l;
	--pin to measure the clock, so the measurment tool does not interfere
	--with the circuit
	clk_l_measure <= clk_l;
	
	buf_parity <= vector_xor(buf);

	--instance of the uart-tx-interface (provided by the course staff)
	uart_tx_instance : uart_tx
	generic map(
		CLK_FREQ	=> CLK_FREQ,
		BAUDRATE	=> BAUDRATE_UART
		)
	port map(
		clk	=> clk_h,
		rst	=> reset,
		send	=> uart_send,
		data	=> uart_data,
		rdy	=> uart_rdy,
		tx	=> uart_tx_out
		);

	process (clk_h, reset)
	--edge detection on the number-request button
	variable button_released : std_logic;
	begin
		if(reset = '1') then
			display_data <= (others => '0');
			display_select <= (others => '1');
			display_select(1) <= '0';
			display_num <= 1;
			display_out <= (others => '0');
			display_div <= 1;
			gen_num_req_down <= '0';
			uart_send <= '0';
			uart_data <= (others => '0');
			uart_out <= (others => '0');
			trng_old <= '0';
			trng_ready <= '0';
			cnt_values <= NUM_TEST_OUTPUT;
		elsif(clk_h = '1' and clk_h'event) then

			-------------------------------------------------------
			------------------- 7 segment display ------------------
			-------------------------------------------------------

			-- Each digit is displayed for 1/8 of the time
			display_div <= inc_overflow(display_div, 10000);
			--decode the current digit to 7-segments (+dot)
			if display_div = 1 then

				------------------------------------------------
				----encoding copied from the exaple given in----
				----lecture 2                               ----
				------------------------------------------------
				case next_digit is
				------------------------------abcdefg.----------
				when "0000"=> display_data <="00000011";  -- '0'
				when "0001"=> display_data <="10011111";  -- '1'
				when "0010"=> display_data <="00100101";  -- '2'
				when "0011"=> display_data <="00001101";  -- '3'
				when "0100"=> display_data <="10011001";  -- '4'
				when "0101"=> display_data <="01001001";  -- '5'
				when "0110"=> display_data <="01000001";  -- '6'
				when "0111"=> display_data <="00011111";  -- '7'
				when "1000"=> display_data <="00000001";  -- '8'
				when "1001"=> display_data <="00001001";  -- '9'
				when "1010"=> display_data <="00010000";  -- 'A'
				when "1011"=> display_data <="00000000";  -- 'B'
				when "1100"=> display_data <="01100010";  -- 'C'
				when "1101"=> display_data <="00000010";  -- 'D'
				when "1110"=> display_data <="01100000";  -- 'E'
				when "1111"=> display_data <="01110000";  -- 'F'
				when others=> display_data <="11111111";
				end case;
				------------------------------------------------

				--prepare for the next digit
				display_select <= (others =>'1');
				display_select(display_num) <= '0';
				display_num <= inc_overflow(display_num, 8);

			end if;

			--4 bits form a digit in hex
			for i in 0 to 3 loop
				if display_num*4-3+i > RNG_WIDTH then 
					next_digit(i) <= '0';
				else next_digit(i)
					<= display_out(display_num*4-3+i);
				end if;
			end loop;

			--------------------------------------------------------
			--------------------- CONTROL UNIT ---------------------
			--------------------------------------------------------

			trng_old <= trng_new;

			gen_num_req_down <= gen_num_req;
			if gen_num_req_down = '1' and gen_num_req = '0' then
				button_released := '1';
			else
				button_released := '0';
			end if;

			--if the uart interface is ready to send a new number
			if uart_cnt = 0 then
				--if there is a fresh value to be sent/displayed
				if trng_ready = '1' then
					--productive mode
					if op_mode = '1' then
						if button_released = '1' then
							display_out <=
								current_value
								(31 downto 0);
							uart_out <=
								current_value;
							uart_cnt <=
								RNG_WIDTH + 8;
							trng_ready <= '0';
						elsif trng_new = '1' and
							trng_old ='0' then
							trng_ready <= '1';
						end if;
						cnt_values <= NUM_TEST_OUTPUT;
					--test mode and still values to be sent
					elsif cnt_values > 0 then
						display_out <= std_logic_vector(
							to_unsigned(
							cnt_values-1,
							display_out'length));
						uart_out <= current_value;
						uart_cnt <= RNG_WIDTH + 8;
						cnt_values <= cnt_values - 1;
						trng_ready <= '0';
					end if;
				elsif trng_new = '1' and trng_old ='0' then
					trng_ready <= '1';
				end if;
				uart_send <= '0';
			--uart ready and there are still bytes left to be sent
			else
				if uart_rdy = '1' then
					--start transmitting
					uart_send <= '1';
					if uart_cnt > 8 then
						for i in 0 to 7 loop
							uart_data(i) <=
								uart_out(uart_cnt+i-16);
						end loop;
					end if;
					uart_cnt <= uart_cnt - 8;

					if trng_new = '1' and trng_old ='0' then
						trng_ready <= '1';
					end if;
				else
					if trng_new = '1' and trng_old ='0' then
						trng_ready <= '1';
					end if;
				end if;
			end if;

		end if;
	end process;

	process (clk_l, reset)

	begin
		if(reset = '1') then
			buf <= (others => '0');
			buf_cntr <= 0;
			ram_addr <= 1;
			ram <= (others => '1');
			trng_new <= '0';
			current_value <= (others => '0');
		elsif(clk_l = '1' and clk_l'event) then
	
			--shift buf one bit, fill the remaining bit with clk_h
			FOR i IN 1 TO PARITY_FILTER_WIDTH-1 LOOP

				buf(i) <= buf(i+1);
			END LOOP;
			buf(PARITY_FILTER_WIDTH) <= clk_h;
		
			--buf_cntr counts the clock cycles of the slow clock.
			--Each time it reaches PARITY_FILTER_WIDTH, the current
			--output of the xor gate is written to the ram. The ram
			--address is increased and the buf_cntr resets to 1.
			--If the ram is full (ram_addr reaches RNG_WIDTH), the
			--oldest values are overwritten
			if buf_cntr = PARITY_FILTER_WIDTH then
				ram(ram_addr) <= buf_parity;
				ram_addr <= inc_overflow(ram_addr, RNG_WIDTH);
				if ram_addr = RNG_WIDTH then
					trng_new <= '1';
					current_value <= ram;
				else
					trng_new <= '0';
				end if;
			end if;

			buf_cntr <= inc_overflow(buf_cntr, PARITY_FILTER_WIDTH);


		end if;
	end process;
end behav;
