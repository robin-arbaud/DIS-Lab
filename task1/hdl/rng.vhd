--------------------------------------------------------------------------------
-- Random Number Generator
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.noise_source;
--
--------------------------------------------------------------------------------
--
entity random_number_generator is
	port(
		clk		: in  std_logic;
		rst		: in  std_logic;
		en		: in  std_logic;
		data	: out std_logic_vector(15 downto 0);
		dataOK	: out std_logic
	);
end random_number_generator;
--
--------------------------------------------------------------------------------
--
architecture behav of random_number_generator is

	-- State variables
	type type_state is (
		IDLE,
		GEN_1,
		GEN_2
	);
	signal state	: type_state := IDLE;

	signal timer	: integer range 0 to 255 := 0;

	-- Post-processing
	signal shiftreg1		: std_logic_vector(255 downto 0) := (others => '0');
	signal shiftreg2		: std_logic_vector( 15 downto 0) := (others => '0');
	signal bitstream		: std_logic := '0'; --input to 1st shiftreg
	signal filt_bitstream	: std_logic := '0'; --input to 2nd shiftreg
	signal en_sr2			: std_logic := '0'; --enable signal for 2nd shiftreg

	signal rst_ns	: std_logic := '1'; --disable signal for noise source

begin
--
--------------------------------------------------------------------------------
-- State and output control

	state_ctrl : process (rst, clk)
	begin

		dataOK <= '0'; --default value

		if rst = '1' then
			state <= IDLE;
			timer <= 0;

		elsif rising_edge(clk) then
			
			if state = IDLE and en = '1' then --generation requested
				state <= GEN_1;

			elsif state = GEN_1 and en = '1' then
				if timer = 240 then --first generation phase
					state <= GEN_2; --fill 1st shift register only
					timer <= 0;
				else
					timer <= timer +1;
				end if;
			
			elsif state = GEN_2 and en = '1' then
				if timer = 16 then  --second generation phase
					state <= GEN_1; --fill both shift registers
					timer <= 0;

					data <= shiftreg2; --output data when second phase
					dataOK <= '1';     --is complete
				else
					timer <= timer +1;
				end if;

			else --enable is zero, no generation requested
				state <= IDLE;
				timer <= 0;
			end if;

		end if;

	end process state_ctrl;
--
--------------------------------------------------------------------------------
-- Post-processing first shift register

	sr1 : process (clk, state)
	begin
		if state = IDLE then
			shiftreg1 <= (others => '0'); --reset
		elsif rising_edge(clk) then
			shiftreg1 <= bitstream & shiftreg1(255 downto 1);
		end if;
	end process sr1;

	filt_bitstream <= shiftreg1(255);
	--this signal should be the sum (xor) of some bits of shiftreg1
	--I could not find which bits exactly, so we simply transfer the
	--last bit, and no post-processing is performed.
--
--------------------------------------------------------------------------------
-- Post-processing second shift register

	sr2 : process (clk, state)
	begin
		if state = IDLE then
			shiftreg2 <= (others => '0'); --reset
		elsif rising_edge(clk) then
			if en_sr2 = '1' then
				shiftreg2 <= filt_bitstream & shiftreg2(15 downto 1);
			end if;
		end if;
	end process sr2;

	en_sr2 <= '1' when state = GEN_2 else '0';
--
--------------------------------------------------------------------------------
-- Noise source instance and control

	ns : entity work.noise_source
		generic map(
			RING_LENGTH  =>   3,
			NUM_OF_RINGS => 110
		)
		port map(
			clk		=> clk,
			rst		=> rst_ns,
			noise	=> bitstream
		);

	rst_ns <= '1' when state = IDLE else '0';
--
--------------------------------------------------------------------------------
--
end behav;
