library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
	port(
		clk_i : in std_logic;
		HSYNC_o : out std_logic;
		VSYNC_o : out std_logic;
		col_o : out unsigned(9 downto 0);
		row_o : out unsigned(9 downto 0);
		valid_o : out std_logic
  );
end vga;

architecture synth of vga is

	signal h_count : unsigned(9 downto 0) := (others => '0');
	signal v_count : unsigned(9 downto 0) := (others => '0');
	signal h_reset : std_logic := '0';

begin

	

	process(clk_i) is
	begin
		if rising_edge(clk_i) then
			col_o   <= h_count;
			row_o   <= v_count;
			valid_o <= '1' when ((h_count < 640) and (v_count < 480)) else '0';
			HSYNC_o <= '0' when ((h_count > 656) and (h_count < 752)) else '1';
			VSYNC_o <= '0' when (v_count > 490 and v_count < 492) else '1';
		
			if (h_count < 800) then
				h_count <= h_count + 1;
				h_reset <= '0';
			else
				h_count <= 10b"0";
				h_reset <= '1';
			end if;
		end if;
	end process;
	
	process(h_reset) is
	begin
		if rising_edge(h_reset) then
			if (v_count < 525) then
				v_count <= v_count + 1;
			else
				v_count <= 10b"0";
			end if;
		end if;
	end process;

end;