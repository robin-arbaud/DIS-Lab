--------------------------------------------------------------------------------
-- Generates a single-cycle pulse from a messy input signal like a push button.
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity pulse_gen is

	generic(
		DELAY	: integer  -- in clock cycles
	);

	port(
		clk	: in std_logic;
		rst	: in std_logic;
		input	: in std_logic;
		outPulse: out std_logic
	);

end pulse_gen;
--
--------------------------------------------------------------------------------
--
architecture beh of pulse_gen is

	signal debCount : integer range 0 to DELAY := 0;

begin
	debounce : process (clk, rst)
	begin
		if rst = '1' then -- asynchronous reset
			debCount <= 0;
			outPulse <= '0';

		elsif rising_edge(clk) then
			if input = '0' then -- input clear
				debCount <= 0;
				outPulse <= '0';
			elsif debCount = DELAY then -- input set since DELAY
				debCount <= 0;
				outPulse <= '1';
			else -- input set but not for long enough yet
				debCount <= debCount +1;
				outPulse <= '0';
			end if;
		end if;

	end process debounce;

end beh;
