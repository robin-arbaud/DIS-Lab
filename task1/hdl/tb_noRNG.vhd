library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--
--------------------------------------------------------------------------------
--
entity tb_noRNG is
end tb_noRNG;
--
-------------------------------------------------------------------------------
--
architecture behav of tb_noRNG is

	--  Declaration of the component that will be instantiated.
	component top is
		port(
			CLK	: in  std_logic;
			RST	: in  std_logic;
			REQ	: in  std_logic;
			MODE	: in  std_logic;
			UART_TX	: out std_logic;
			DISPLAY_SEG: out std_logic_vector(7 downto 0);
			DISPLAY_AN : out std_logic_vector(7 downto 0);
			RNG_rng_data : in  std_logic_vector (15 downto 0);
			RNG_data_ok  : in  std_logic;
			RNG_req_data : out std_logic
		);
	end component;

	for dut: top use entity work.top_noRNG;
	
	constant CLK_PERIOD : time := 10 ns;
	signal clk, rst, req, mode, uart_tx, rng_data_ok, rng_req_data : std_logic;
	signal display_seg, display_an : std_logic_vector (7 downto 0);
	signal rng_rng_data : std_logic_vector (15 downto 0);
--
-------------------------------------------------------------------------------
--
begin

	dut: top
	port map (
		CLK => clk,
	 	RST => rst,
		REQ => req,
		MODE => mode,
		UART_TX => uart_tx,
		DISPLAY_SEG => display_seg,
		DISPLAY_AN => display_an,
		RNG_rng_data => rng_rng_data,
		RNG_data_ok => rng_data_ok,
		RNG_req_data => rng_req_data
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
		req <= '0';
		mode <= '0';
		rng_rng_data <= "0000000000000000";
		rng_data_ok <= '0';
--
-------------------------------------------------------------------------------
--
		wait for CLK_PERIOD/2;
		rst <= '1';

		wait for CLK_PERIOD;
		rst <= '0';

		wait for CLK_PERIOD;
		req <= '1';

		wait for 12 ms;
		req <= '0';

		wait for CLK_PERIOD;
		rng_rng_data <= "0100001100100001";
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 200 us;
		rng_rng_data <= "1000011101100101";
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;
		wait for 200 us;
		rng_rng_data <= "1111111111111111";
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';
		
		wait for 2 ms;

		wait for 200 us;
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';
		rng_rng_data <= "1010101111001101";

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';
		rng_rng_data <= "1000011101100101";

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';
		rng_rng_data <= "0100001100100001";

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 1 ms;

		wait for 200 us;
		rng_data_ok <= '1';

		wait for CLK_PERIOD;
		rng_data_ok <= '0';

		wait for 10 ms;
--
-------------------------------------------------------------------------------
--
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		assert false report "Simulation Finished" severity failure;
	end process;

end behav;
