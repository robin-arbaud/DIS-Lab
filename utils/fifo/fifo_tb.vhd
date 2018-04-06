library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity fifo_tb is
end fifo_tb;
--
-------------------------------------------------------------------------------
--
architecture behav of fifo_tb is

	--  Declaration of the component that will be instantiated.
	component fifo is

		generic(
			DATA_BASE_WIDTH	: integer;
			DATA_IN_WIDTH	: integer;
			DATA_OUT_WIDTH	: integer;
			FIFO_DEPTH	: integer
		);
		port(
			clk	: in  std_logic;
			rst	: in  std_logic;
			write	: in  std_logic;
			dataIn	: in  std_logic_vector (DATA_IN_WIDTH *DATA_BASE_WIDTH -1 downto 0);
			read	: in  std_logic;
			dataOut	: out std_logic_vector (DATA_OUT_WIDTH*DATA_BASE_WIDTH -1 downto 0);
			empty	: out std_logic;
			full	: out std_logic
		);

	end component;

	for dut: fifo use entity work.fifo_buffer;
	
	constant CLK_PERIOD : time := 10 ns;
	signal clk, rst, write, read, empty, full : std_logic;
	signal dataIn, dataOut : std_logic_vector (7 downto 0);
--
-------------------------------------------------------------------------------
--
begin

	dut: fifo
	generic map (
		DATA_BASE_WIDTH	=> 8,
		DATA_IN_WIDTH	=> 1,
		DATA_OUT_WIDTH	=> 1,
		FIFO_DEPTH	=> 8
	)
	port map (
		clk => clk,
	 	rst => rst,
		write => write ,
		dataIn => dataIn,
		read => read,
		dataOut => dataOut,
		empty => empty,
		full => full
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
		rst <= '0';
		write <= '0';
		dataIn <= "00000000";
		read <= '0';
		wait for CLK_PERIOD/2;
		assert empty = '1' report "not empty at startup" severity error;
--
-------------------------------------------------------------------------------
-- Simultaneaous write and read
		wait for CLK_PERIOD;
		write <= '1';
		read <= '1';
		assert empty = '1' report "not empty before 1st write" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000001";
		assert empty = '0' report "still empty after 1st write" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000010";
		assert dataOut = "00000000" report "read1" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000100";
		assert dataOut = "00000001" report "read2" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00001000";
		assert dataOut = "00000010" report "read3" severity error;
--
-------------------------------------------------------------------------------
-- Write until full
		wait for CLK_PERIOD;
		read <= '0';
		dataIn <= "00010000";
		assert dataOut = "00000100" report "read4" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00100000";
		assert dataOut = "00000100" report "still reading ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "01000000";
		assert dataOut = "00000100" report "still reading ?" severity error;
		
		wait for CLK_PERIOD;
		dataIn <= "10000000";

		wait for CLK_PERIOD;
		dataIn <= "00010001";

		wait for CLK_PERIOD;
		dataIn <= "00010010";

		wait for CLK_PERIOD;
		dataIn <= "00010100";
		assert full = '0' report "full already ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00011000";
		assert full = '1' report "not full yet ?" severity error;
--
-------------------------------------------------------------------------------
-- Restart reading
		wait for CLK_PERIOD;
		read <= '1';
		dataIn <= "00100001";
		assert dataOut = "00000100" report "changed value ?" severity error;
		assert full = '1' report "not full ?" severity error;


		wait for CLK_PERIOD;
		dataIn <= "00100010";
		assert dataOut = "00001000" report "read5" severity error;
		assert full = '0' report "still full ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00100100";
		assert dataOut = "00010000" report "read6" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00101000";
		assert dataOut = "00100000" report "read7" severity error;
--
-------------------------------------------------------------------------------
-- Stop writing, read until empty
		wait for CLK_PERIOD;
		write <= '0';
		dataIn <= "11111111";
		assert dataOut = "01000000" report "read8" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10000000" report "read9" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010001" report "read10" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010010" report "read11" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010100" report "read12" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00100010" report "read13" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00100100" report "read14" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00101000" report "read15" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00101000" report "read16" severity error;

		wait for CLK_PERIOD;
		assert empty = '1' report "not empty ?" severity error;
		assert dataOut = "00101000" report "still reading ?" severity error;

		wait for CLK_PERIOD;
		read <= '0';
		assert empty = '1' report "not empty ?" severity error;
		assert dataOut = "00101000" report "still reading ?" severity error;
--
-------------------------------------------------------------------------------
-- Reset test : write 3 values, start reading, then reset
		wait for CLK_PERIOD;
		write <= '1';

		wait for CLK_PERIOD;
		assert empty = '0' report "Still empty ?" severity error;

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;
		read <= '1';

		wait for CLK_PERIOD;
		assert dataOut = "11111111" report "read17" severity error;
		
		wait for CLK_PERIOD;
		rst <= '1';

		wait for CLK_PERIOD/10; --reset is asynchronous
		assert empty = '1' report "not empty at reset" severity error;

		wait for 9*CLK_PERIOD/10;
		assert empty = '1' report "not empty at reset" severity error;
		
		wait for CLK_PERIOD;
		read <= '0';
		write <= '0';
		dataIn <= "00000000";
		rst <= '0';
		assert empty = '1' report "not empty after reset" severity error;

		wait for CLK_PERIOD;
		assert empty = '1' report "not empty after reset" severity error;
--
-------------------------------------------------------------------------------
-- Rerun the whole test to check if reset has no weird effect.
-------------------------------------------------------------------------------
-- Simultaneaous write and read
		wait for CLK_PERIOD;
		write <= '1';
		read <= '1';
		assert empty = '1' report "not empty before 1st write" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000001";
		assert empty = '0' report "still empty after 1st write" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000010";
		assert dataOut = "00000000" report "read1" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00000100";
		assert dataOut = "00000001" report "read2" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00001000";
		assert dataOut = "00000010" report "read3" severity error;
--
-------------------------------------------------------------------------------
-- Write until full
		wait for CLK_PERIOD;
		read <= '0';
		dataIn <= "00010000";
		assert dataOut = "00000100" report "read4" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00100000";
		assert dataOut = "00000100" report "still reading ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "01000000";
		assert dataOut = "00000100" report "still reading ?" severity error;
		
		wait for CLK_PERIOD;
		dataIn <= "10000000";

		wait for CLK_PERIOD;
		dataIn <= "00010001";

		wait for CLK_PERIOD;
		dataIn <= "00010010";

		wait for CLK_PERIOD;
		dataIn <= "00010100";
		assert full = '0' report "full already ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00011000";
		assert full = '1' report "not full yet ?" severity error;
--
-------------------------------------------------------------------------------
-- Restart reading
		wait for CLK_PERIOD;
		read <= '1';
		dataIn <= "00100001";
		assert dataOut = "00000100" report "changed value ?" severity error;
		assert full = '1' report "not full ?" severity error;


		wait for CLK_PERIOD;
		dataIn <= "00100010";
		assert dataOut = "00001000" report "read5" severity error;
		assert full = '0' report "still full ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00100100";
		assert dataOut = "00010000" report "read6" severity error;

		wait for CLK_PERIOD;
		dataIn <= "00101000";
		assert dataOut = "00100000" report "read7" severity error;
--
-------------------------------------------------------------------------------
-- Stop writing, read until empty
		wait for CLK_PERIOD;
		write <= '0';
		dataIn <= "11111111";
		assert dataOut = "01000000" report "read8" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10000000" report "read9" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010001" report "read10" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010010" report "read11" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00010100" report "read12" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00100010" report "read13" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00100100" report "read14" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00101000" report "read15" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "00101000" report "read16" severity error;

		wait for CLK_PERIOD;
		assert empty = '1' report "not empty ?" severity error;
		assert dataOut = "00101000" report "still reading ?" severity error;

		wait for CLK_PERIOD;
		read <= '0';
		assert empty = '1' report "not empty ?" severity error;
		assert dataOut = "00101000" report "still reading ?" severity error;

		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		assert false report "Simulation Finished" severity failure;
	end process;

end behav;
