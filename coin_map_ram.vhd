library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Basic dual-ported RAM module
-- This infers one or more EBRs in Radiant, and you can simulate it as well
entity coin_map is
  port(
	clk : in std_logic;
	r_addr : in std_logic_vector(10 downto 0);
	r_data : out std_logic;
	w_addr : in std_logic_vector(10 downto 0);
	w_data : in std_logic;
	w_enable : in std_logic
  );
end;

architecture synth of coin_map is
	type ramtype is array(1200 downto 0) of
	 std_logic;
	signal mem : ramtype;

begin
	process (clk) is begin
		if rising_edge(clk) then
		if w_enable = '1' then
			mem(to_integer(unsigned(w_addr))) <= w_data;
		end if;
			r_data <= mem(to_integer(unsigned(r_addr)));
end if;
	end process;
end;