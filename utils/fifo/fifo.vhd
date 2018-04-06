--------------------------------------------------------------------------------
-- Single Clock synchronous FIFO buffer
--
-- Data are captured and outputed at falling edges of the clock, for
--		good integration with rising edge synchronous control.
--
-- Read and write data widths can be set independantly.
--
-- Read (resp Write) signals are ignored if the buffer is empty (resp full).
--
-- based on from http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
--------------------------------------------------------------------------------
--

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--
--------------------------------------------------------------------------------
--
entity fifo_buffer is
	Generic (
		constant DATA_BASE_WIDTH: integer; --storage unit length
		constant DATA_IN_WIDTH	: integer; --number of storage units stored on write
		constant DATA_OUT_WIDTH	: integer; --number of storage units loaded on read
		constant FIFO_DEPTH	: integer  --number of available storage units
	);
	Port ( 
		clk	: in  std_logic;
		rst	: in  std_logic;
		write	: in  std_logic;
		dataIn	: in  std_logic_vector (DATA_IN_WIDTH *DATA_BASE_WIDTH -1 downto 0);
		read	: in  std_logic;
		dataOut	: out std_logic_vector (DATA_OUT_WIDTH*DATA_BASE_WIDTH -1 downto 0);
		empty	: out std_logic;
		full	: out std_logic
	);
end fifo_buffer;
--
--------------------------------------------------------------------------------
--
architecture behavioral of fifo_buffer is

	type memory is array (0 to FIFO_DEPTH -1) of
		 std_logic_vector (DATA_BASE_WIDTH -1 downto 0);
	signal mem : memory;

	signal head : integer range 0 to FIFO_DEPTH -1 := 0; --write address
	signal tail : integer range 0 to FIFO_DEPTH -1 := 0; --read address
	signal lead : integer range 0 to FIFO_DEPTH := 0; --advance of head over tail
	signal readCd  : std_logic := '0';
	signal writeCd : std_logic := '0';

begin
	readCd  <= '1' when (read = '1')  and (lead >= DATA_OUT_WIDTH) else '0';
	--read is requested and possible
	writeCd <= '1' when (write = '1') and (lead <= FIFO_DEPTH - DATA_IN_WIDTH) else '0';
	--write is requested and possible

	process(clk, rst)
	begin
		if rst = '1' then --asynchronous reset
			head <= 0;
			tail <= 0;
			lead <= 0;
			
		elsif falling_edge(clk) then
--
--------------------------------------------------------------------------------
--
			--read procedure
			if readCd = '1' then

				for count in 1 to DATA_OUT_WIDTH loop
					dataOut( count*DATA_BASE_WIDTH -1
						downto (count-1)*DATA_BASE_WIDTH ) 
						<= mem(tail + count -1);
				end loop;

				tail <= (tail + DATA_OUT_WIDTH) mod FIFO_DEPTH;
				
				if writeCd = '0' then --if no simultaneous write
					lead <= lead - DATA_OUT_WIDTH; --decrease lead
				else
					lead <= lead - DATA_OUT_WIDTH + DATA_IN_WIDTH;
				end if;
			end if;
--
--------------------------------------------------------------------------------
--
			--write procedure
			if writeCd = '1' then

				for count in 1 to DATA_IN_WIDTH loop
					mem(head + count -1) <=
						dataIn(count*DATA_BASE_WIDTH -1
						downto (count-1)*DATA_BASE_WIDTH);
				end loop;

				head <= (head + DATA_IN_WIDTH) mod FIFO_DEPTH;

				if readCd = '0' then --if no simultaneous read
					lead <= lead + DATA_IN_WIDTH; --increase lead
				-- else do nothing, update already done
				end if;
			end if;
		end if;
	end process;
--
--------------------------------------------------------------------------------
--
	--set output flags
	empty <= '1' when (lead < DATA_OUT_WIDTH) else '0';
	full  <= '1' when (lead > FIFO_DEPTH - DATA_IN_WIDTH) else '0';

end behavioral;
