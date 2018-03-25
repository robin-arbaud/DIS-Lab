--------------------------------------------------------------------------------
-- Simple edge detector. Generate a synchronous pulse at rising edge of input.
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--
--------------------------------------------------------------------------------
--
entity edge_detector is

	port(
		clk	: in std_logic;
		input	: in std_logic;
		output	: out std_logic
	);

end edge_detector;
--
--------------------------------------------------------------------------------
--
architecture beh of edge_detector is

	signal prevInput : std_logic; 

begin
	process (clk)
	begin
		if rising_edge(clk) then
			if input = '1' and prevInput = '0' then
				output <= '1';
			else
				output <= '0';
			end if;
			prevInput <= input;
		end if;
	end process;
end beh;
