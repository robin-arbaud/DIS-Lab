--------------------------------------------------------------------------------
-- Noise source for the Random Number Generator
--
-- Hold reset high to disable noise generation.
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.ring_osc;
--
--------------------------------------------------------------------------------
--
entity noise_source is
	generic(
		RING_LENGTH  : integer;
		NUM_OF_RINGS : integer
	);
	port(
		clk		: in  std_logic;
		rst		: in  std_logic;
		noise	: out std_logic
	);
end noise_source;
--
--------------------------------------------------------------------------------
--
architecture behav of noise_source is

	signal osc		: std_logic_vector(0 to NUM_OF_RINGS -1) := (others => '0');
	signal osc_xored: std_logic_vector(0 to NUM_OF_RINGS -1) := (others => '0');

begin
--
--------------------------------------------------------------------------------
-- Instantiate array of ring oscillators

	osc_gen : for count in 0 to NUM_OF_RINGS -1 generate
		ro : entity work.ring_osc
			generic map(
				LENGTH	=> RING_LENGTH
			)
			port map(
				reset	=> rst,
				fout	=> osc(count)
			);
	end generate osc_gen;
--
--------------------------------------------------------------------------------
-- Connect ring oscillators outputs

	process (osc, osc_xored)
	begin

		for i in osc'range loop
			if (i = 0) then
				osc_xored(i) <= osc(i);
			else
				osc_xored(i) <= osc(i) xor osc_xored(i-1);
			end if;
		end loop;

	end process;
--
--------------------------------------------------------------------------------
-- Output resulting noise

	setOut : process (clk)
	begin
		if rising_edge(clk) then
			noise <= osc_xored(NUM_OF_RINGS -1);
		end if;
	end process setOut;

end behav;
