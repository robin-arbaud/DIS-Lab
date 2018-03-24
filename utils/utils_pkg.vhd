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
	component seven_seg_display is

		generic(
			CLK_FREQ : integer
		);
		port(
			clk   : in std_logic;
			useMask: in std_logic_vector(7 downto 0);
			data0 : in std_logic_vector(3 downto 0);
			data1 : in std_logic_vector(3 downto 0);
			data2 : in std_logic_vector(3 downto 0);
			data3 : in std_logic_vector(3 downto 0);
			data4 : in std_logic_vector(3 downto 0);
			data5 : in std_logic_vector(3 downto 0);
			data6 : in std_logic_vector(3 downto 0);
			data7 : in std_logic_vector(3 downto 0);
			seg   : out std_logic_vector(7 downto 0);
			anode : out std_logic_vector(7 downto 0)
		);

	end component seven_seg_display;
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
