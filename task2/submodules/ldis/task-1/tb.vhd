
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity tb is
end tb;

architecture behav of tb is

	component rng
		port (op_mode		: in std_logic;
			reset		: in std_logic;
			gen_num_req	: in std_logic;
			clk_h		: in std_logic;
			clk_l		: in std_logic;
			clk_l_cpy	: out std_logic;
			clk_l_inv	: out std_logic;
			clk_l_measure	: out std_logic;
			uart_tx_out	: out std_logic;
			display_data	: out std_logic_vector(7 downto 0);
			display_select	: out std_logic_vector(8 downto 1)
			);
	end component;

	signal op_mode		: std_logic;
	signal reset		: std_logic;
	signal gen_num_req	: std_logic;
	signal clk_h		: std_logic;
	signal clk_l		: std_logic;
	signal clk_l_cpy	: std_logic;
	signal clk_l_inv	: std_logic;
	signal clk_l_measure	: std_logic;
	signal uart_tx_out	: std_logic;

	signal display_data	: std_logic_vector(7 downto 0);
	signal display_select	: std_logic_vector(8 downto 1);

	constant period_l	: time := 25 ns; --40 us;
	constant period_h	: time := 10 ns;
	signal ended		: std_logic := '0';

begin

	dut : rng
	port map (op_mode	=> op_mode,
		reset		=> reset,
		gen_num_req	=> gen_num_req,
		clk_h		=> clk_h,
		clk_l		=> clk_l,
		clk_l_cpy	=> clk_l_cpy,
		clk_l_inv	=> clk_l_inv,
		clk_l_measure	=> clk_l_measure,
		uart_tx_out	=> uart_tx_out,
		display_data	=> display_data,
		display_select	=> display_select
		);


	clk_l_process :process
	variable seed1, seed2 : positive;
	variable rand : real;
	begin
		uniform(seed1, seed2, rand);
		clk_l <= '0';
		wait for period_l/2*(rand*0.2+0.9);
		clk_l <= '1';
		wait for period_l/2*(rand*0.2+0.9);
		if ended = '1' then
			wait;
		end if;
	end process;

	clk_h_process :process
	begin
		clk_h <= '0';
		wait for period_h/2;
		clk_h <= '1';
		wait for period_h/2;
		if ended = '1' then
			wait;
		end if;
	end process;

	stimuli : process
	begin
		op_mode <= '0';
		gen_num_req <= '0';

		reset <= '1';
		wait for 100 ns;
		reset <= '0';
		wait for 100 ns;

		wait for 200000 * period_l;

		ended <= '1';

		wait;
	end process;

end behav;

