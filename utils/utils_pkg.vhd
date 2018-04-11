--------------------------------------------------------------------------------
-- Package for generic utilities.
--------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package utils_pkg is
--
--------------------------------------------------------------------------------
--
	component debouncer is
		generic(
			DELAY	: integer; --in us
			CLK_FREQ: integer  --in Hz
		);
	
		port(
			clk		: in  std_logic;
			rst		: in  std_logic;
			input	: in  std_logic;
			output	: out std_logic
		);
	end component debouncer;
--
--------------------------------------------------------------------------------
--
	component edge_detector is
		port(
			clk		: in  std_logic;
			input	: in  std_logic;
			output	: out std_logic
		);
	end component edge_detector;
--
--------------------------------------------------------------------------------
--
	component seven_seg_display is
		generic(
			CLK_FREQ : integer --in Hz
		);
		port(
			clk  	: in  std_logic;
			useMask	: in  std_logic_vector(7 downto 0);
			-- Specify which display are actually used
			data0	: in  std_logic_vector(3 downto 0);
			data1	: in  std_logic_vector(3 downto 0);
			data2	: in  std_logic_vector(3 downto 0);
			data3	: in  std_logic_vector(3 downto 0);
			data4	: in  std_logic_vector(3 downto 0);
			data5	: in  std_logic_vector(3 downto 0);
			data6	: in  std_logic_vector(3 downto 0);
			data7	: in  std_logic_vector(3 downto 0);
			seg  	: out std_logic_vector(7 downto 0);
			anode	: out std_logic_vector(7 downto 0)
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
			clk		: in std_logic;
			rst		: in std_logic;
			send	: in std_logic;
			data	: in std_logic_vector(7 downto 0);
			rdy		: out std_logic;
			tx		: out std_logic
		);
	end component uart_tx;
--
--------------------------------------------------------------------------------
--
	component fifo_buffer is
		generic (
			constant DATA_BASE_WIDTH: integer;	--storage unit length
			constant DATA_IN_WIDTH	: integer;	--number of units stored on write
			constant DATA_OUT_WIDTH	: integer;	--number of units loaded on read
			constant FIFO_DEPTH		: integer  	--number of available units
		);
		port ( 
			clk		: in  std_logic;
			rst		: in  std_logic;
			write	: in  std_logic;
			dataIn	: in  std_logic_vector (DATA_IN_WIDTH *DATA_BASE_WIDTH -1
																	  downto 0);
			read	: in  std_logic;
			dataOut	: out std_logic_vector (DATA_OUT_WIDTH*DATA_BASE_WIDTH -1
																	  downto 0);
			empty	: out std_logic;
			full	: out std_logic
		);
	end component fifo_buffer;

end utils_pkg;
