--------------------------------------------------------------------------------
-- Block to convert an integer into an 8 byte string (LE32 function for Argon2)
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity le32 is

	port(
		input : in integer;
		output: out std_logic_vector(8*8 -1 downto 0)
	);

end le32;
--
--------------------------------------------------------------------------------
--
architecture behav of le32 is

	signal int_vector : std_logic_vector(31 downto 0);

begin

	int_vector <= std_logic_vector( to_unsigned (input, 32) );

	output <= int_vector & int_vector;

end behav;