library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--
--------------------------------------------------------------------------------
--
entity fifo_tb2 is
end fifo_tb2;
--
-------------------------------------------------------------------------------
--
architecture behav of fifo_tb2 is

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
	signal dataIn : std_logic_vector (15 downto 0);
	signal dataOut: std_logic_vector ( 7 downto 0);
--
-------------------------------------------------------------------------------
--
begin

	dut: fifo
	generic map (
		DATA_BASE_WIDTH	=> 8,
		DATA_IN_WIDTH	=> 2,
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
		dataIn <= "0000000000000000";
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
		dataIn <= "0000001000000001";
		assert empty = '0' report "still empty after 1st write" severity error;

		wait for CLK_PERIOD;
		dataIn <= "0000100000000100";
		assert dataOut = "00000000" report "read1" severity error;

		wait for CLK_PERIOD;
		dataIn <= "0010000000010000";
		assert dataOut = "00000000" report "read2" severity error;

		wait for CLK_PERIOD;
		dataIn <= "1000000001000000";
		assert dataOut = "00000001" report "read3" severity error;

		wait for CLK_PERIOD;
		dataIn <= "1000001010000001";
		assert dataOut = "00000010" report "read4" severity error;

		wait for CLK_PERIOD;
		dataIn <= "1000100010000100";
		assert dataOut = "00000100" report "read5" severity error;
		assert full = '1' report "not full ?" severity error;

		wait for CLK_PERIOD;
		dataIn <= "1001000110010000";
		assert dataOut = "00001000" report "read6" severity error;
		
		wait for CLK_PERIOD;
		dataIn <= "1001010010010010";
		assert dataOut = "00010000" report "read7" severity error;
		assert full = '1' report "not full ?" severity error;
		
		wait for CLK_PERIOD;
		dataIn <= "1001001110011000";
		assert dataOut = "00100000" report "read8" severity error;
--
-------------------------------------------------------------------------------
-- read until empty
		wait for CLK_PERIOD;
		write <= '0';
		dataIn <= "1111111111111111";
		assert dataOut = "01000000" report "read9" severity error;
		assert full = '1' report "not full ?" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10000000" report "read10" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10000001" report "read11" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10000010" report "read12" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10010000" report "read13" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10010001" report "read14" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10011000" report "read15" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10010011" report "read16" severity error;

		wait for CLK_PERIOD;
		assert dataOut = "10010011" report "read16" severity error;
		assert empty = '1' report "not empty ?" severity error;
--
-------------------------------------------------------------------------------
-- 		
		wait for CLK_PERIOD;
		assert false report "Simulation Finished" severity failure;
	end process;

end behav;
