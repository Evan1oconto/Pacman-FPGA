library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NEScontroller is
	port(
		controller_data_i : in std_logic;
		controller_clk_i : in std_logic; -- NESclk
		
		controller_latch_o : out std_logic;
		controller_clk_o : out std_logic;
		input_register_o : out std_logic_vector(7 downto 0)
	);
end NEScontroller;

architecture struct of NEScontroller is
	
	signal NEScount : unsigned(7 downto 0) := (others => '0');
	signal input_register : std_logic_vector(7 downto 0);
	
	signal enable_clk : std_logic := '0';
	
begin
	controller_clk_o <= controller_clk_i and enable_clk;
	
	process (controller_clk_i) is
	begin
		if rising_edge(controller_clk_i) then
		
			if (NEScount > 8x"07") then
				input_register_o <= not input_register;
			end if;
			
		end if;
		if falling_edge(controller_clk_i) then
			
			NEScount <= NEScount + 1;
			if (NEScount = 8x"FE") then
				controller_latch_o <= '1';
			end if;
			
			if (NEScount = 8x"FF") then
				controller_latch_o <= '0';
			end if;
			
			if (NEScount < 8x"08") then
				enable_clk <= '1';
				input_register <= input_register(6 downto 0) & controller_data_i;
			else
				enable_clk <= '0';
			end if;
		end if;
	end process;
	
	
	
	
end;