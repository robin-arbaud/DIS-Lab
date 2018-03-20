--------------------------------------------------------------------------------
-- Package for small utilities.
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--
--------------------------------------------------------------------------------
--
package utils_pkg is

	component pulse_gen is

		generic(
			DELAY	: integer  -- in clock cycles
		);

		port(
			clk	: in std_logic;
			rst	: in std_logic;
			input	: in std_logic;
			outPulse: out std_logic
		);

	end component pulse_gen;

end utils_pkg;
