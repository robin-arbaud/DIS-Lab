-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--Testbench vor a blake2b implementation in VHDL

--authors Benedikt Tutzer and Dinka Milovancev
--april 2018

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blake2b is
	port (
		--high active reset signal
		reset		: in	std_logic;
		
		--system clock
		clk		: in	std_logic;

		--chunk of message to be hashed
		message		: in	std_logic_vector(128*8-1 downto 0);

		--desired hash lenght in bytes
		hash_len	: in	integer range 1 to 64;

		--high as long as chunks are sent
		valid_in	: in	std_logic;

		--number of bytes to be hashed
		message_len	: in	integer range 0 to 1024;

		--ready for next chunk
		compress_ready	: out	std_logic;

		--high when the last chunk is sent
		last_chunk	: in	std_logic;

		--high when the output is valid
		valid_out	: out	std_logic;

		--the generated hash in little endian
		hash		:out	std_logic_vector(64*8-1 downto 0)
	);
end blake2b;

architecture behav of blake2b is

	--SIGMA as defined in the paper
	type sig_t is array(0 to 11, 0 to 15) of INTEGER range 0 to 15;
	constant SIGMA : sig_t :=
	(
		( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15),
		(14,10, 4, 8, 9,15,13, 6, 1,12, 0, 2,11, 7, 5, 3),
		(11, 8,12, 0, 5, 2,15,13,10,14, 3, 6, 7, 1, 9, 4),
		( 7, 9, 3, 1,13,12,11,14, 2, 6, 5,10, 4, 0,15, 8),
		( 9, 0, 5, 7, 2, 4,10,15,14, 1,11,12, 6, 8, 3,13),
		( 2,12, 6,10, 0,11, 8, 3, 4,13, 7, 5,15,14, 1, 9),
		(12, 5, 1,15,14,13, 4,10, 0, 7, 6, 3, 9, 2, 8,11),
		(13,11, 7,14,12, 1, 3, 9, 5, 0,15, 4, 8, 6, 2,10),
		( 6,15,14, 9,11, 3, 0, 8,12, 2,13, 7, 1, 4,10, 5),
		(10, 2, 8, 4, 7, 6, 1, 5,15,11, 9,14, 3,12,13, 0),
		( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15),
		(14,10, 4, 8, 9,15,13, 6, 1,12, 0, 2,11, 7, 5, 3)
	);

	--indizes for the 8 mixing rounds. 1 row per count, 1 column per operator
	type ind_t is array(0 to 7, 0 to 5) of INTEGER range 0 to 15;
	constant ind : ind_t :=
	(
		( 0, 4, 8,12, 0, 1),
		( 1, 5, 9,13, 2, 3),
		( 2, 6,10,14, 4, 5),
		( 3, 7,11,15, 6, 7),

		( 0, 5,10,15, 8, 9),
		( 1, 6,11,12,10,11),
		( 2, 7, 8,13,12,13),
		( 3, 4, 9,14,14,15)
	);

	type arr8 is array(0 to 7) of std_logic_vector(63 downto 0);
	type arr16 is array(15 downto 0) of std_logic_vector(63 downto 0);
	
	--initialization vector for blake2b
	constant VI : arr8 :=
	(
		X"6A09E667F3BCC908",
		X"BB67AE8584CAA73B",
		X"3C6EF372FE94F82B",
		X"A54FF53A5F1D36F1",
		X"510E527FADE682D1",
		X"9B05688C2B3E6C1F",
		X"1F83D9ABFB41BD6B",
		X"5BE0CD19137E2179"
	);

	--states for the state machine
	type state_type is (STATE_IDLE, STATE_PREPARE, STATE_WAIT, STATE_MIX_H, STATE_COMPRESS,
		STATE_MIX_A, STATE_MIX_B, STATE_DONE);
	signal state : state_type;

	--persistent state vector
	signal h : arr8;
	--local state vector
	signal v : arr16;

	--current chunk of the message
	signal current_chunk : std_logic_vector(128*8-1 downto 0);
	--wether this is the last chunk or not
	signal seen_last : std_logic;
	--the number of valid bytes in the message
	signal total_bytes : integer range 0 to 1024;

	--counts compress iterations
	signal ci_done : integer range 0 to 11;
	--counts mixing iterations
	signal mi_done : integer range 0 to 7;
	--counts operations in a single mixing round
	signal mio_left : std_logic_vector(1 downto 0);

	--counts the number of bytes that have been compressed
	signal cmprd : std_logic_vector(127 downto 0);

begin

	process(clk)
	--help variables for the mixing operations. These correspond
	--to the variable names in the paper
	variable a : std_logic_vector(63 downto 0);
	variable b : std_logic_vector(63 downto 0);
	variable c : std_logic_vector(63 downto 0);
	variable d : std_logic_vector(63 downto 0);
	variable x : std_logic_vector(63 downto 0);
	variable y : std_logic_vector(63 downto 0);
	variable help_sigma_x : integer range 0 to 15;
	variable help_sigma_y : integer range 0 to 15;
	begin
		if reset = '1' then
			state <= STATE_IDLE;
			current_chunk <= (others => '0');
			seen_last <= '0';
			compress_ready <= '1';
			h <= (others => (others => '0'));
			v <= (others => (others => '0'));
			cmprd <= (others => '0');
			mio_left <= "00";
			valid_out <= '0';
			hash <= (others => '0');
		elsif rising_edge(clk) then
			--assign the right local vector and message to the variables according to the index table
			a := v(ind(mi_done, 0));
			b := v(ind(mi_done, 1));
			c := v(ind(mi_done, 2));
			d := v(ind(mi_done, 3));
			help_sigma_x := SIGMA(ci_done, ind(mi_done,4));
			x := current_chunk(help_sigma_x*64+63 downto help_sigma_x*64);
			help_sigma_y := SIGMA(ci_done, ind(mi_done,5));
			y := current_chunk(help_sigma_y*64+63 downto help_sigma_y*64);

			case(state) is
				when STATE_IDLE =>
					--initialize the persistent state vector
					h(1 to 7) <= VI(1 to 7);
					h(0) <= VI(0) xor (X"00000000010100" &
						std_logic_vector(
						to_unsigned(hash_len, 8)));
					--no bytes yet received
					if valid_in = '1' then
						--if a message chunk is received, it is saved together with all
						--inputs and the state machine moves to the prepare state
						state <= STATE_PREPARE;
						current_chunk <= message;
						seen_last <= last_chunk;
						ci_done <= 0;
						compress_ready <= '0';
						total_bytes <= message_len;
						--if this was the last chunk, the number of received bytes is
						--equal to the length of the received message. Otherwise it is
						--increased by 128.
						if last_chunk = '1' then
							cmprd <= std_logic_vector(to_unsigned(message_len, 128));
						else
							cmprd <= std_logic_vector(
								unsigned(cmprd) + 128);
						end if;
						--the entity is not ready to receive new input
						valid_out <= '0';
					end if;
				when STATE_PREPARE =>
					--the persistent state vector is copied onto the local state vector
					for i in 0 to 7 loop
						V(i) <= h(i);
					end loop;
					V(8) <= VI(0);
					V(9) <= VI(1);
					V(10) <= VI(2);
					V(11) <= VI(3);
					--the number of received bytes is mixed into the vector
					V(12) <= VI(4) xor cmprd(63 downto 0);
					V(13) <= VI(5) xor cmprd(127 downto 64);
					--inverted if the last chunk is sent
					if seen_last = '1' then
						V(14) <= not VI(6);
					else
						V(14) <= VI(6);
					end if;
					V(15) <= VI(7);
					--reset the counter for the compression stage
					ci_done <= 0;
					--move on to the compress state
					state <= STATE_COMPRESS;

				when STATE_WAIT =>
					--a subsequent message chunk was received (not the first)
					if valid_in = '1' then
						state <= STATE_PREPARE;
						current_chunk <= message;
						seen_last <= last_chunk;
						compress_ready <= '0';
						if last_chunk = '1' then
							cmprd <= std_logic_vector(to_unsigned(message_len,128));
						else
							cmprd <= std_logic_vector(
								unsigned(cmprd) + 128);
						end if;
					end if;

				when STATE_COMPRESS =>
					--reset the counter for the mixing stage
					mi_done <= 0;
					--start mixing
					state <= STATE_MIX_A;
				when STATE_MIX_A =>
					--additions as defined by blake2b
					case mio_left is
						when "11"|"01" =>
					v(ind(mi_done, 2)) <= std_logic_vector(
						unsigned(c)+unsigned(d));
						when "00" =>
					v(ind(mi_done, 0)) <= std_logic_vector(
						unsigned(a)+unsigned(b)+unsigned(x));
						when "10" =>
					v(ind(mi_done, 0)) <= std_logic_vector(
						unsigned(a)+unsigned(b)+unsigned(y));
						when others =>
					end case;

					state <= STATE_MIX_B;
				when STATE_MIX_B =>
					--xor's and shifts as defined by blake2b
					case mio_left is
						when "00" =>
					v(ind(mi_done,3)) <= std_logic_vector(
						unsigned(d xor a) ror 32);
						when "11" =>
					v(ind(mi_done,1)) <= std_logic_vector(
						unsigned(b xor c) ror 24);
						when "10" =>
					v(ind(mi_done,3)) <= std_logic_vector(
						unsigned(d xor a) ror 16);
						when "01" =>
					v(ind(mi_done,1)) <= std_logic_vector(
						unsigned(b xor c) ror 63);
						when others =>
					end case;

					--last mix
					if mi_done = 7 and mio_left = "01" then
						--also last compression
						if ci_done = 11 then
							--also last chunk
							if seen_last = '1' then
								state <=
								STATE_DONE;
							else
								state <=
								STATE_MIX_H;
							end if;
							--ready to receive a new chunk
							compress_ready <= '1';
						else
							--next compression
							state <= STATE_COMPRESS;
							ci_done <=
								ci_done + 1;
						end if;
					else
						if mio_left = "01" then
							mi_done <=
								mi_done +1;
						end if;
						state <= STATE_MIX_A;
					end if;
					mio_left <= std_logic_vector(unsigned(mio_left) + 3);
				when STATE_DONE =>
					--write output
					for i in 0 to 7 loop
						hash(i*64+63 downto i*64) <= h(i) xor v(i) xor v(i+8);
					end loop;
					valid_out <= '1';
					cmprd <= (others => '0');
					state <= STATE_IDLE;
				when STATE_MIX_H =>
					state <= STATE_WAIT;
					--mix into h
					for i in 0 to 7 loop
						h(i) <= h(i) xor v(i) xor v(i+8);
					end loop;
				when others =>
					state <= STATE_IDLE;
			end case;
		end if;
	end process;
end behav;
