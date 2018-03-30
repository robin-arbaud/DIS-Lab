--------------------------------------------------------------------------------
-- Single Clock synchronous FIFO buffer
--
-- Data are captured and outputed at falling edges of the clock, for
--	good integration with rising edge synchronous control.
--
-- Read (resp Write) signals are ignored if the buffer is empty (resp full).
--
-- Inspired from http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
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
		constant DATA_WIDTH	: integer;
		constant FIFO_DEPTH	: integer
	);
	Port ( 
		clk	: in  std_logic;
		rst	: in  std_logic;
		write	: in  std_logic;
		dataIn	: in  std_logic_vector (DATA_WIDTH -1 downto 0);
		read	: in  std_logic;
		dataOut	: out std_logic_vector (DATA_WIDTH -1 downto 0);
		empty	: out std_logic;
		full	: out std_logic
	);
end fifo_buffer;
--
--------------------------------------------------------------------------------
--
architecture behavioral of fifo_buffer is

	type memory is array (0 to FIFO_DEPTH -1) of
		 std_logic_vector (DATA_WIDTH -1 downto 0);
	signal mem : memory;

	signal head : integer range 0 to FIFO_DEPTH -1 := 0; --write address
	signal tail : integer range 0 to FIFO_DEPTH -1 := 0; --read address
	signal lead : integer range 0 to FIFO_DEPTH := 0; --advance of head
							  --      over tail
	signal readCd  : std_logic := '0';
	signal writeCd : std_logic := '0';

begin
	readCd  <= '1' when (read = '1')   and (lead /= 0) else '0';
	--read is requested and possible
	writeCd <= '1' when (write = '1')  and (lead /= FIFO_DEPTH) else '0';
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
				dataOut <= mem(tail); --output data

				if tail = FIFO_DEPTH -1 then --update tail
					tail <= 0;
				else
					tail <= tail +1;
				end if;

				if writeCd = '0' then --if no simultaneous write
					lead <= lead -1; --decrease lead
				end if;
			end if;
--
--------------------------------------------------------------------------------
--
			--write procedure
			if writeCd = '1' then
				mem(head) <= dataIn; --store input data

				if head = FIFO_DEPTH -1 then --update head
					head <= 0;
				else
					head <= head +1;
				end if;

				if readCd = '0' then --if no simultaneous read
					lead <= lead +1; --increase lead
				end if;
			end if;
		end if;
	end process;
--
--------------------------------------------------------------------------------
--
	--set output flags
	empty <= '1' when (lead = 0) else '0';
	full  <= '1' when (lead = FIFO_DEPTH) else '0';

end behavioral;
