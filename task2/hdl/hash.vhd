--------------------------------------------------------------------------------
-- Block to perform the variable-length hashing for Argon2.

-- Never set the inValid flag is the available flag is not already set. This
-- would result in loss of data, as there is no input buffer.
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

use work.blake2b;
use work.le32;
--
--------------------------------------------------------------------------------
--
entity hash is

	port(
		clk			: in  std_logic;
		rst			: in  std_logic;
		tagSize		: in  integer range 1 to 1024;
		msgIn		: in  std_logic_vector( 128*8 -1 downto 0);
		inValid		: in  std_logic;
		msgLength	: in  integer range 1 to 1024; --in bytes

		hash		: out std_logic_vector(1024*8 -1 downto 0);
		outValid	: out std_logic;
		newDataRdy	: out std_logic;
		newReqRdy	: out std_logic
	);

end hash;
--
--------------------------------------------------------------------------------
--
architecture behav of hash is

	-- State variables
	type type_state is (
		IDLE,
		INIT,
		INIT_END,
		B2_WAIT_INIT,
		CONT,
		CONT_END
	);
	signal state: type_state := IDLE;

	signal t : integer range 1 to 1024;
	signal r : integer range 0 to 30;

	signal le32_t	: std_logic_vector(8*8 -1 downto 0);
	signal min_64_t	: integer range 1 to 64;

	-- Bytes already transmitted to Blake2 in first phase
	signal in_byte_count	: integer range 1 to 1024 := 1;
	-- Position of last byte in last chunk of input	
	signal last_byte_idx	: integer range 0 to 127;
	-- Number of hashes performed in second phase
	signal iter_count		: integer range 1 to 31 := 1;

	-- Blake2b module control signals
	--inputs
	signal b2_msg_chk	: std_logic_vector(128*8 -1 downto 0);
	signal b2_new_chk	: std_logic;
	signal b2_last_chk	: std_logic;
	signal b2_msg_length	: integer range 0 to 1032;
	signal b2_hash_length	: integer range 1 to 64;
	--outputs
	signal b2_rdy		: std_logic;
	signal b2_finish	: std_logic;
	signal b2_result	: std_logic_vector(64*8 -1 downto 0);

	-- Storage for V_i
	type Vmem is array (1 to 31) of std_logic_vector(64*8 -1 downto 0);
	signal v : Vmem;

begin

	r <= integer( ceil( real(t)/real(32) )) -2 when t > 64 else 0;

	with state select
		newDataRdy <= '0' when CONT,
					  '0' when CONT_END,
					  '1' when IDLE,
					  b2_rdy when others;

	newReqRdy <= '1' when state = IDLE else '0';


	process (clk, rst)
	begin

		--default values
		if rising_edge(clk) then
			b2_new_chk	<= '0';
			b2_last_chk	<= '0';
		end if;

		if rst = '1' then
			hash	<= (others => '0');
			v		<= (others => (others => '0'));

			state	<= IDLE;
			in_byte_count	<= 1;
			iter_count		<= 1;
			b2_msg_chk		<= (others => '0');


		elsif rising_edge(clk) then
--
--------------------------------------------------------------------------------
-- Initialization

			if state = IDLE and inValid = '1' then

				t <= tagSize;
				b2_msg_length <= 8 + msgLength;
				last_byte_idx <= msgLength mod 128;
				iter_count <= 1;
				outValid <= '0';

				if msgLength > 128 then
					-- more chunks to come
					b2_msg_chk <= msgIn;
					b2_new_chk <= '1';
					in_byte_count <= 128;
					state <= INIT;

				elsif b2_msg_length <= 128 then
					-- no more chunks to come, and room for LE32(T)
					b2_msg_chk((last_byte_idx+8)*8 -1 downto 0)
						 <= le32_t & msgIn(last_byte_idx*8 -1 downto 0);
					b2_msg_chk(128*8 -1 downto (last_byte_idx+8)*8)
						 <= (others => '0');
					b2_new_chk  <= '1';
					b2_last_chk <= '1';
					state <= B2_WAIT_INIT;

				else
					--no more chunks to come but no room for LE32(T)
					b2_msg_chk
						 <= le32_t( (128-last_byte_idx)*8 -1 downto 0)
						  & msgIn(last_byte_idx*8 -1 downto 0);
					b2_new_chk	<= '1';
					state <= INIT_END;

				end if;
--
--------------------------------------------------------------------------------
-- Initial hashing
	
			elsif state = INIT and inValid = '1' and b2_rdy = '1' then

				if in_byte_count < b2_msg_length -8 -128 then
					-- more chunks to come
					b2_msg_chk	<= msgIn;
					b2_new_chk	<= '1';
					in_byte_count <= in_byte_count + 128;

				else -- last chunk of data

					if last_byte_idx < 120 then --no need for additional chunk

						b2_msg_chk((last_byte_idx+8)*8 -1 downto 0)
							 <= le32_t & msgIn(last_byte_idx*8 -1 downto 0);
						b2_msg_chk(128*8 -1 downto (last_byte_idx+8)*8)
							 <= (others => '0');
						b2_new_chk  <= '1';
						b2_last_chk <= '1';
						state <= B2_WAIT_INIT;


					else --additional chunk needed for concatenation of LE32(T)
						b2_msg_chk
							 <= le32_t( (128-last_byte_idx)*8 -1 downto 0)
							  & msgIn(last_byte_idx*8 -1 downto 0);

						state <= INIT_END;
					end if;

				end if;
--
--------------------------------------------------------------------------------
-- End of initial hashing

			elsif state = INIT_END and b2_rdy = '1'then

				b2_msg_chk((last_byte_idx -120)*8 -1 downto 0)
					<= le32_t(8*8 -1 downto (128-last_byte_idx)*8);
				b2_new_chk  <= '1';
				b2_last_chk <= '1';
				state <= B2_WAIT_INIT;
--
--------------------------------------------------------------------------------
-- Wait for Blake2 completion

			elsif state = B2_WAIT_INIT and b2_finish = '1' then	

				if t <= 64 then --done, output result
					hash(t*8 -1 downto 0) <= b2_result(t*8 -1 downto 0);
					outValid <= '1';
					state <= IDLE;
				else
					if r>=2 then state <= CONT;
					else state <= CONT_END;
					end if;
				end if;
--
--------------------------------------------------------------------------------
-- Continue hashing to extend the output size

			elsif state = CONT and b2_finish = '1' then

				v(iter_count) <= b2_result;

				b2_msg_chk(128*8 -1 downto 64*8) <= (others => '0');
				b2_msg_chk( 64*8 -1 downto    0) <= b2_result;
				b2_new_chk	<= '1';
				b2_last_chk	<= '1';
				b2_msg_length <= 64;

				iter_count <= iter_count +1;

				if iter_count >= r then
					state <= CONT_END;
				end if;
--
--------------------------------------------------------------------------------
-- Concatenate hashes into final output

			elsif state = CONT_END and b2_finish = '1' then

				v(iter_count) <= b2_result;

				-- V_(r+1)
				hash((t-32*r)*8 -1 downto 0) <= b2_result((t-32*r)*8 -1 downto 0);
				-- V_r to V_1
				for k in r downto 1 loop
					hash((t-32*(k-1))*8 -1 downto (t-32*k)*8) <= v(k)(64*8 -1 downto 32*8);
				end loop;

				outValid <= '1';

				state <= IDLE;
			end if;

		end if;
	end process;
--
--------------------------------------------------------------------------------
-- Blake2b module instantiation

	h : entity work.blake2b
		port map(
			reset			=> rst,
			clk				=> clk,
			message			=> b2_msg_chk,
			valid_in		=> b2_new_chk,
			last_chunk		=> b2_last_chk,
			message_len		=> b2_msg_length,
			hash_len		=> b2_hash_length,
			compress_ready	=> b2_rdy,
			valid_out		=> b2_finish,
			hash			=> b2_result
		);

	with state select
		b2_hash_length <= 64 when CONT,
						  t-32*r when CONT_END,
						  min_64_t when others;

	min_64_t <= t when t<64 else 64;
--
--------------------------------------------------------------------------------
-- LE32 module instantiation

	le32 : entity work.le32
		port map(
			input	=> t,
			output	=> le32_t
		);
--
--------------------------------------------------------------------------------
--
end behav;				