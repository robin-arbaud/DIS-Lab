--------------------------------------------------------------------------------
-- Ring Oscillator
--
-- Slightly adapted from:
-- http://www.lothar-miller.de/s9y/archives/90-Ringoszillator.html
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
--
--------------------------------------------------------------------------------
--
entity ring_osc is
	generic(
		LENGTH: integer --number of oscillators (must be odd)
	);
	port(
		reset : in  std_logic;
		fout  : out std_logic
	);
end ring_osc;
--
--------------------------------------------------------------------------------
--
architecture Behavioral of ring_osc is

	signal ring    : std_logic_vector(LENGTH -1 downto 0);
	-- makes sure that the ring will not be optimized out
	attribute KEEP : string;
	attribute KEEP of ring : signal is "true";

begin
	process (ring, reset) begin

		for i in ring'range loop

			if i = ring'left then
				if reset='1' then
					ring(i) <= '1';
				else
					ring(i) <= not ring(0) after 1 ns;
				end if;

			else
				 ring(i) <= not ring(i+1) after 1 ns;
			end if;

		end loop;
	end process;

	fout <= ring(0);

end Behavioral;
