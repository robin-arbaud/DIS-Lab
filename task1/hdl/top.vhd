library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.uart_tx;
use work.utils_pkg.seven_seg_display;
use work.controller;
--
--------------------------------------------------------------------------------
--
entity top is
	port
	(
		CLK			: in  std_logic;
		RST			: in  std_logic;
		REQ			: in  std_logic;
		MODE		: in  std_logic;
		UART_TX		: out std_logic;
		DISPLAY_SEG	: out std_logic_vector(7 downto 0);
		DISPLAY_AN	: out std_logic_vector(7 downto 0)
	);
end top;
--
--------------------------------------------------------------------------------
--
architecture beh of top is

	constant CLK_FREQ	: integer := 100E6;
	constant BAUDRATE	: integer := 38400;

	-- Controller <--> RNG
	signal rng_data		: std_logic_vector(15 downto 0);
	signal data_ok		: std_logic;
	signal req_data		: std_logic;

	-- Controller <--> UART
	signal uart_rdy		: std_logic;
	signal uart_snd		: std_logic;
	signal uart_data	: std_logic_vector(7 downto 0);

	-- Controller --> 7 segments display
	signal seg_use_mask	: std_logic_vector(7 downto 0);
	signal seg_data0	: std_logic_vector(3 downto 0);
	signal seg_data1	: std_logic_vector(3 downto 0);
	signal seg_data2	: std_logic_vector(3 downto 0);
	signal seg_data3	: std_logic_vector(3 downto 0);
	signal seg_data4	: std_logic_vector(3 downto 0);
	signal seg_data5	: std_logic_vector(3 downto 0);
	signal seg_data6	: std_logic_vector(3 downto 0);
	signal seg_data7	: std_logic_vector(3 downto 0);

	-- Inputs --> controller
	signal req_clean	: std_logic := '0';
	signal req_pulse	: std_logic := '0';
	signal mode_clean	: std_logic := '0';

begin

	ctrl : entity work.controller
		generic map(
			CLK_FREQ => CLK_FREQ
		)
		port map(
			clk		=> CLK,
			rst		=> RST,
			mode	=> MODE,
			request	=> req_pulse,
			rngData	=> rng_data,
			dataOK	=> data_ok,
			reqData	=> req_data,
			uartRdy	=> uart_rdy,
			uartSnd	=> uart_snd,
			uartData=> uart_data,
			useMask	=> seg_use_mask,
			data0	=> seg_data0,
			data1	=> seg_data1,
			data2	=> seg_data2,
			data3	=> seg_data3,
			data4	=> seg_data4,
			data5	=> seg_data5,
			data6	=> seg_data6,
			data7	=> seg_data7
		);
		

	uart_trans : entity work.uart_tx
		generic map(
			CLK_FREQ=> CLK_FREQ,
			BAUDRATE=> BAUDRATE
		)
		port map(
			clk		=> CLK,
			rst		=> RST,
			send	=> uart_snd,
			data	=> uart_data,
			rdy		=> uart_rdy,
			tx		=> UART_TX
		);


	rng : entity work.random_number_generator
		port map(
			clk		=> CLK,
			rst		=> RST,
			en		=> req_data,
			data	=> rng_data,
			dataOK	=> data_ok
		);


	display : entity work.seven_seg_display
		generic map(
			CLK_FREQ=> CLK_FREQ
		)
		port map(
			clk		=> CLK,
			useMask	=> seg_use_mask,
			data0	=> seg_data0,
			data1	=> seg_data1,
			data2	=> seg_data2,
			data3	=> seg_data3,
			data4	=> seg_data4,
			data5	=> seg_data5,
			data6	=> seg_data6,
			data7	=> seg_data7,
			seg		=> DISPLAY_SEG,
			anode	=> DISPLAY_AN
		);


	debMode : entity work.debouncer
		generic map(
			DELAY	=> 10000,
			CLK_FREQ=> CLK_FREQ
		)
		port map(
			clk		=> CLK,
			rst		=> RST,
			input	=> MODE,
			output	=> mode_clean
		);


	debRequest : entity work.debouncer
		generic map(
			DELAY	=> 10000,
			CLK_FREQ=> CLK_FREQ
		)
		port map(
			clk		=> CLK,
			rst		=> RST,
			input	=> REQ,
			output	=> req_clean
		);


	pulseRequest : entity work.edge_detector
		port map(
			clk		=> CLK,
			input	=> req_clean,
			output	=> req_pulse
		);

end beh;
