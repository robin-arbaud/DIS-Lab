-------------------------------------------------------------------------------
-- 7-segment displays controller for the Nexys 4 DDR board
-- 
-- Hex numbers a, b, c, d are displayed in lower-case
-- Set useMask bits to selects which displays shall actually be used
-- If th n_th bit in use Mask is 0, corresponding input data_n will be ignored
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--
-------------------------------------------------------------------------------
--
entity seven_seg_display is

	generic(
		CLK_FREQ : integer -- in Hz
	);
	port(
		clk   : in std_logic;
		useMask: in std_logic_vector(7 downto 0);
		-- Specify which displays are actually used
		data0 : in std_logic_vector(3 downto 0);
		data1 : in std_logic_vector(3 downto 0);
		data2 : in std_logic_vector(3 downto 0);
		data3 : in std_logic_vector(3 downto 0);
		data4 : in std_logic_vector(3 downto 0);
		data5 : in std_logic_vector(3 downto 0);
		data6 : in std_logic_vector(3 downto 0);
		data7 : in std_logic_vector(3 downto 0);
		seg   : out std_logic_vector(7 downto 0);
		anode : out std_logic_vector(7 downto 0)
	);

end seven_seg_display;
--
-------------------------------------------------------------------------------
--
architecture behavioral of seven_seg_display is

	signal bin : std_logic_vector(3 downto 0) := "0000";
	signal currentDisplay : integer range 0 to 7 := 0;
	constant DURATION : integer := CLK_FREQ/333; -- Switch display every 3 ms
	signal timer : integer range 0 to DURATION := 0;

begin

	selectDisplay : process (clk)
	begin	
		if rising_edge(clk) then
			timer <= timer +1;
			
			if timer = DURATION then
				timer <= 0;

				if currentDisplay = 7 then currentDisplay <= 0;
				else currentDisplay <= currentDisplay +1;
				end if;
			end if;
		end if;

	end process selectDisplay;
--
-------------------------------------------------------------------------------
--
	mux : process (currentDisplay)
	begin
		case currentDisplay is -- select data to display
			when 0 => bin <= data0;
			when 1 => bin <= data1;
			when 2 => bin <= data2;
			when 3 => bin <= data3;
			when 4 => bin <= data4;
			when 5 => bin <= data5;
			when 6 => bin <= data6;
			when 7 => bin <= data7;
		end case;

		case currentDisplay is -- select which display
			when 0 => anode <= "11111110";
			when 1 => anode <= "11111101";
			when 2 => anode <= "11111011";
			when 3 => anode <= "11110111";
			when 4 => anode <= "11101111";
			when 5 => anode <= "11011111";
			when 6 => anode <= "10111111";
			when 7 => anode <= "01111111";
		end case;
	
	end process mux;
--
-------------------------------------------------------------------------------
--
	bin2seg : process (bin)
	begin
		if useMask(currentDisplay) = '1' then
		-- if the currentDisplay shall be used
			case bin is
				---------------------abcdefg.----------
				when "0000"=> seg <="00000011";  -- '0'
				when "0001"=> seg <="10011111";  -- '1'
				when "0010"=> seg <="00100101";  -- '2'
				when "0011"=> seg <="00001101";  -- '3'
				when "0100"=> seg <="10011001";  -- '4'
				when "0101"=> seg <="01001001";  -- '5'
				when "0110"=> seg <="01000001";  -- '6'
				when "0111"=> seg <="00011111";  -- '7'
				when "1000"=> seg <="00000001";  -- '8'
				when "1001"=> seg <="00001001";  -- '9'
				when "1010"=> seg <="00000101";  -- 'a'
				when "1011"=> seg <="11000001";  -- 'b'
				when "1100"=> seg <="11100101";  -- 'c'
				when "1101"=> seg <="10000101";  -- 'd'
				when "1110"=> seg <="01100001";  -- 'E'
				when "1111"=> seg <="01110001";  -- 'F'
				when others=> seg <="11111111"; -- nothing
			end case;
		else seg <= "11111111"; -- display is not used
		end if;

	end process bin2seg;

end behavioral;
