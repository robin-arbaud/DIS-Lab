--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.utils_pkg.debouncer;
use work.utils_pkg.edge_detector;
use work.utils_pkg.fifo_buffer;
--
-------------------------------------------------------------------------------
--
entity controller is
	generic(
		CLK_FREQ : integer --in Hz
	);
	port(
		clk	: in std_logic;
		rst	: in std_logic;

		--input controls
		mode	: in std_logic;
		request	: in std_logic;

		--RNG interface
		rngData	: in std_logic_vector(15 downto 0);
		dataOK	: in std_logic;
		reqData	: out std_logic;

		--UART interface
		uartRdy	: in std_logic;
		uartSnd	: out std_logic;
		uartData: out std_logic_vector(7 downto 0);

		--7 segments display interface
		useMask	: out std_logic_vector(7 downto 0);
		data0	: out std_logic_vector(3 downto 0);
		data1	: out std_logic_vector(3 downto 0);
		data2	: out std_logic_vector(3 downto 0);
		data3	: out std_logic_vector(3 downto 0);
		data4	: out std_logic_vector(3 downto 0);
		data5	: out std_logic_vector(3 downto 0);
		data6	: out std_logic_vector(3 downto 0);
		data7	: out std_logic_vector(3 downto 0)
	);
end controller;
--
-------------------------------------------------------------------------------
--
architecture behav of controller is

	type type_mode is (
		PROD,
		TEST
	);
	type type_state is (
		IDDLE,
		PENDING
	);
	signal state_mode	: type_mode  := PROD;
	signal state_state	: type_state := IDDLE;

	signal output_OK	: std_logic := '0';
	signal fifo_read_req	: std_logic := '0';
	signal sent_bytes	: integer range 0 to 16E5 := 0;
	signal requested_bytes	: integer := 0;

	signal fifo_empty	: std_logic := '1';
	signal fifo_full	: std_logic := '0';

	signal rng_data_swap	: std_logic_vector(15 downto 0);
	signal issue_data	: std_logic_vector(7  downto 0);
	signal uart_send	: std_logic := '0';

	signal modeClean	: std_logic := '0';
	signal requestClean	: std_logic := '0';
	signal requestPulse	: std_logic := '0';


begin
--
-------------------------------------------------------------------------------
-- Main control and RNG interface
	ctrl : process (clk, rst)
	begin
		if rst = '1' then
			state_state	<= IDDLE;

		elsif rising_edge(clk) then

			if state_state = IDDLE and requestPulse = '1' then
				case state_mode is
				when PROD => requested_bytes <= 16;
				when TEST => requested_bytes <= 16E5;
				end case;

				state_state <= PENDING;

			elsif sent_bytes >= requested_bytes then
				state_state <= IDDLE;
			end if;
		end if;
	end process ctrl;


	state_mode <= PROD when (modeClean = '0') else TEST;
	reqData <= '1' when (fifo_full = '0') and (state_state = PENDING) else '0';
--
-------------------------------------------------------------------------------
-- FIFO instance and control signals
	fifo : entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH	=> 8,
			DATA_IN_WIDTH	=> 2,
			DATA_OUT_WIDTH	=> 1,
			FIFO_DEPTH	=> 16
		)
		port map(
			clk	=> clk,
			rst	=> rst,
			write	=> dataOK,
			dataIn	=> rng_data_swap,
			read	=> fifo_read_req,
			dataOut	=> issue_data,
			empty	=> fifo_empty,
			full	=> fifo_full
		);

	rng_data_swap <= rngData(7 downto 0) & rngData(15 downto 8);


	process (clk) -- Set the output as OK at falling edge, since the buffer
	begin         -- is synchronized with the falling edge.
		if falling_edge(clk) then
			output_ok <= fifo_read_req;
		end if;

		if rising_edge(clk) then
			if (fifo_empty = '0' and uartRdy = '1') and (output_ok = '0' and state_state = PENDING) and uart_send = '0' then
				fifo_read_req <= '1';
			else
				fifo_read_req <= '0';
			end if;
		end if;
	end process;
--
-------------------------------------------------------------------------------
-- Output interfaces
	uartSnd <= uart_send;

	outIf : process (clk)
	begin	
		if state_state = IDDLE then
			sent_bytes <= 0;

		elsif rising_edge(clk) then

			if output_OK = '1' then

				-- UART
				uartData   <= issue_data;
				uart_send  <= '1';
				sent_bytes <= sent_bytes +1;

				-- 7 segments display
				case state_mode is
				when PROD =>
					--display 4 LSBs
					case sent_bytes is
					when 15 =>	data0 <= issue_data(3 downto 0);
							data1 <= issue_data(7 downto 4);
					when 14 =>	data2 <= issue_data(3 downto 0);
							data3 <= issue_data(7 downto 4);
					when 13 =>	data4 <= issue_data(3 downto 0);
							data5 <= issue_data(7 downto 4);
					when 12 =>	data6 <= issue_data(3 downto 0);
							data7 <= issue_data(7 downto 4);
					when others =>	NULL;
					end case;

					useMask <= "11111111";
					
				when TEST =>
					--7 segments display unused
					useMask	<= "00000000";
				end case;

			else
				uart_send <= '0';
			end if;
		end if;
	end process outIf;
--
-------------------------------------------------------------------------------
-- clean inputs
	debMode : entity work.debouncer
		generic map(
			DELAY	=> 10000,
			CLK_FREQ=> CLK_FREQ
		)
		port map(
			clk	=> clk,
			rst	=> rst,
			input	=> mode,
			output	=> modeClean
		);

	debRequest : entity work.debouncer
		generic map(
			DELAY	=> 10000,
			CLK_FREQ=> CLK_FREQ
		)
		port map(
			clk	=> clk,
			rst	=> rst,
			input	=> request,
			output	=> requestClean
		);

	pulseRequest : entity work.edge_detector
		port map(
			clk	=> clk,
			input	=> requestClean,
			output	=> requestPulse
		);
end behav;
