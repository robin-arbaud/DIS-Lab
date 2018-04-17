library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity controller_tb is
end controller_tb;
--
-------------------------------------------------------------------------------
--
architecture behav of controller_tb is

	component control is
		generic(
			CLK_FREQ: integer
			);
		port(
			clk		: in  std_logic;
			rst		: in  std_logic;
			mode	: in  std_logic;			
			request	: in  std_logic;
			rngData : in  std_logic_vector (15 downto 0);
			dataOK  : in  std_logic;
			reqData : out std_logic;
			uartRdy	: in  std_logic;
			uartSnd	: out std_logic;
			uartData: out std_logic_vector(7 downto 0);
			useMask : out std_logic_vector(7 downto 0);
			data0	: out std_logic_vector(3 downto 0);
			data1	: out std_logic_vector(3 downto 0);
			data2	: out std_logic_vector(3 downto 0);
			data3	: out std_logic_vector(3 downto 0);
			data4	: out std_logic_vector(3 downto 0);
			data5	: out std_logic_vector(3 downto 0);
			data6	: out std_logic_vector(3 downto 0);
			data7	: out std_logic_vector(3 downto 0)
		);
	end component;

	for dut: control use entity work.controller;
	
	constant CLK_PERIOD : time := 10 ns;

	signal clk,     rst,      request,  mode     : std_logic;
	signal data_ok, req_data, uart_rdy, uart_snd : std_logic;
	signal rng_data	: std_logic_vector (15 downto 0);
	signal uart_data: std_logic_vector ( 7 downto 0);
	signal use_mask	: std_logic_vector ( 7 downto 0);
	signal data0, data1, data2, data3, data4, data5, data6, data7
					: std_logic_vector ( 3 downto 0);
--
-------------------------------------------------------------------------------
--
begin

	dut: control
	generic map (
		CLK_FREQ=> 100E6
		)
	port map (
		clk		=> clk,
	 	rst		=> rst,
		request => request,
		mode	=> mode,
		rngData	=> rng_data,
		dataOK	=> data_ok,
		reqData	=> req_data,
		uartRdy => uart_rdy,
		uartSnd => uart_snd,
		uartData=> uart_data,
		useMask	=> use_mask,
		data0	=> data0,
		data1	=> data1,
		data2	=> data2,
		data3	=> data3,
		data4	=> data4,
		data5	=> data5,
		data6	=> data6,
		data7	=> data7
	);

	clk_gen : process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process clk_gen;


	test: process
	begin
		rst			<= '0';
		request		<= '0';
		mode		<= '0';
		rng_data	<= "0000000000000000";
		data_ok		<= '0';
		uart_rdy	<= '0';
		wait for CLK_PERIOD/2;
--
-------------------------------------------------------------------------------
-- Production mode - Generation of 1 number

		wait for CLK_PERIOD;
		request <= '1';

		wait for CLK_PERIOD;
		request <= '0';
		assert req_data = '1' report "No data requested" severity error;

		wait for CLK_PERIOD;
		rng_data <= "0100001100100001";
		data_ok  <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD;
		rng_data <= "1000011101100101";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data" severity error;
		assert uart_data = "00100001" report "wrong data sent" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse" severity warning;
		assert uart_data = "00100001" report "data loss" severity error;
		wait for CLK_PERIOD/2;
		rng_data <= "1100101110101001";
		data_ok <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 2" severity error;
		assert uart_data = "01000011" report "wrong data sent 2" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 2" severity warning;
		assert uart_data = "01000011" report "data loss 2" severity error;
		wait for CLK_PERIOD/2;

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 3" severity error;
		assert uart_data = "01100101" report "wrong data sent 3" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 3" severity warning;
		wait for CLK_PERIOD/2;

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 4" severity error;
		assert uart_data = "10000111" report "wrong data sent 4" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 4" severity warning;
		wait for CLK_PERIOD/2;
		
		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';
--
-------------------------------------------------------------------------------
-- FIFO buffer should now be empty : check for output data consistency

		wait for CLK_PERIOD;
		uart_rdy <= '1';
		
		wait for CLK_PERIOD;
		assert uart_snd = '0' report "Sending dummy data" severity error;
		assert uart_data = "11001011" report "data unstable" severity error;
		
		wait for CLK_PERIOD;
		assert uart_snd = '0' report "Sending dummy data" severity error;
		assert uart_data = "11001011" report "data unstable" severity error;
--
-------------------------------------------------------------------------------
-- Check if the system stops by itself once the request is completed

		wait for CLK_PERIOD;
		rng_data <= "0000111111101101";
		data_ok <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "not sending data" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		rng_data <= "0100001100100001";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		rng_data <= "1000011101100101";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';
		
		wait for CLK_PERIOD;
		uart_rdy <= '0';
		
		wait for CLK_PERIOD;
		rng_data <= "1100101110101001";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';
		
		wait for CLK_PERIOD;
		rng_data <= "0000111111101101";
		data_ok <= '1';
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';
		data_ok <= '0';

		wait for CLK_PERIOD;
		
		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';
		assert req_data = '0' report "req_data after completion" severity error;
--
-------------------------------------------------------------------------------
--	Reset test

		wait for CLK_PERIOD;
		request <= '1';

		wait for CLK_PERIOD;
		request <= '0';
		assert req_data = '1' report "No data requested" severity error;

		wait for CLK_PERIOD;
		rng_data <= "1111111111111111";
		data_ok  <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD;
		rng_data <= "1111111111111111";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		rst <= '1';

		wait for CLK_PERIOD;
		assert req_data = '0' report "data requested at reset" severity error;
		assert uart_snd = '0' report "send attempt at reset" severity error;
	
		wait for CLK_PERIOD;
		rst <= '0';
	
		wait for CLK_PERIOD;
		assert req_data = '0' report "data requested at reset" severity error;
		assert uart_snd = '0' report "send attempt at reset" severity error;
--
-------------------------------------------------------------------------------
--	Rerun the beginning of the test to check reset after-effects.

		uart_rdy	<= '0';
		data_ok		<= '0';

		wait for CLK_PERIOD;
		request <= '1';

		wait for CLK_PERIOD;
		request <= '0';
		assert req_data = '1' report "No data requested" severity error;

		wait for CLK_PERIOD;
		rng_data <= "0100001100100001";
		data_ok  <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD;
		rng_data <= "1000011101100101";
		data_ok <= '1';
		uart_rdy <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data" severity error;
		assert uart_data = "00100001" report "wrong data sent" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse" severity warning;
		assert uart_data = "00100001" report "data loss" severity error;
		wait for CLK_PERIOD/2;
		rng_data <= "1100101110101001";
		data_ok <= '1';

		wait for CLK_PERIOD;
		data_ok <= '0';
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 2" severity error;
		assert uart_data = "01000011" report "wrong data sent 2" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 2" severity warning;
		assert uart_data = "01000011" report "data loss 2" severity error;
		wait for CLK_PERIOD/2;

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 3" severity error;
		assert uart_data = "01100101" report "wrong data sent 3" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 3" severity warning;
		wait for CLK_PERIOD/2;

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD/2;
		assert uart_snd = '1' report "No sending data 4" severity error;
		assert uart_data = "10000111" report "wrong data sent 4" severity error;
		wait for CLK_PERIOD/2;
		uart_rdy <= '0';

		wait for CLK_PERIOD/2;
		assert uart_snd = '0' report "send is no pulse 4" severity warning;
		wait for CLK_PERIOD/2;
		
		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';

		wait for CLK_PERIOD;
		uart_rdy <= '1';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		uart_rdy <= '0';
--
-------------------------------------------------------------------------------
-- FIFO buffer should now be empty : check for output data consistency

		wait for CLK_PERIOD;
		uart_rdy <= '1';
		
		wait for CLK_PERIOD;
		assert uart_snd = '0' report "Sending dummy data" severity error;
		assert uart_data = "11001011" report "data unstable" severity error;
		
		wait for CLK_PERIOD;
		assert uart_snd = '0' report "Sending dummy data" severity error;
--
-------------------------------------------------------------------------------
--
		assert false report "Simulation Finished" severity failure;
	end process;

end behav;
