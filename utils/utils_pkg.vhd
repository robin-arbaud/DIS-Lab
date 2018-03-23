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
--
--------------------------------------------------------------------------------
--
	component uart_rx is
		generic(
			CLK_FREQ : integer; -- in Hz
			BAUDRATE : integer  -- in bit/s
		);
		port(
			clk      : in std_logic;
			rst      : in std_logic;
			rx       : in std_logic;
			data     : out std_logic_vector(7 downto 0);
			data_new : out std_logic
		);
	end component uart_rx;
--
--------------------------------------------------------------------------------
--
	component uart_tx is
		generic(
			CLK_FREQ : integer; -- in Hz
			BAUDRATE : integer  -- in bit/s
		);
		port(
			clk   : in std_logic;
			rst   : in std_logic;
			send  : in std_logic;
			data  : in std_logic_vector(7 downto 0);
			rdy   : out std_logic;
			tx    : out std_logic
		);
	end component uart_tx;

end utils_pkg;
