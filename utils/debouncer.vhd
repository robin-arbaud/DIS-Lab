--------------------------------------------------------------------------------
-- Simple debouncer
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity debouncer is

	generic(
		DELAY	: integer; --in us
		CLK_FREQ: integer --in Hz
	);

	port(
		clk	: in std_logic;
		rst	: in std_logic;
		input	: in std_logic;
		output	: out std_logic --debounced input
	);

end debouncer;
--
--------------------------------------------------------------------------------
--
architecture behavioral of debouncer is

	constant DELAY_CC : integer := (CLK_FREQ/1000000)*DELAY; --in clock cycles
	signal debCount : integer range 0 to DELAY_CC := 0;
	signal debValue : std_logic := '0';

begin

	debounce : process (clk, rst)
	begin
		if rst= '1' then --asynchronous reset
			debCount <= 0;
			debValue <= '0';
			output   <= '0';

		elsif rising_edge(clk) then

			if (debValue xor input) = '1' then
			--input has changed
				debCount <= 0;
				debValue <= input;
			elsif debCount = DELAY_CC then
			--input has not changed since DELAY
				debCount <= 0;
				output <= debValue;
			else
			--input has not changed since less time than DELAY
				debCount <= debCount +1;
			end if;
		end if;

	end process debounce;

end behavioral;				
