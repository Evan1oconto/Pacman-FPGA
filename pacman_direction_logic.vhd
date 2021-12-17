library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pacman_direction_logic is
	port(
		clk_i : in std_logic;
		reset_i : in std_logic;
		input_register_i : in std_logic_vector(7 downto 0);
		direction_control_o : out std_logic_vector(1 downto 0)
	);
end pacman_direction_logic;

architecture synth of pacman_direction_logic is

begin

	-- happens at start of new frame
	process(clk_i) is
	begin
		if rising_edge(clk_i) then
			if reset_i then
				direction_control_o <= "10";
			else
				if input_register_i(3) then -- up
					direction_control_o <= "00";
				elsif input_register_i(2) then -- down
					direction_control_o <= "01";
				elsif input_register_i(1) then -- left
					direction_control_o <= "10";
				elsif input_register_i(0) then -- right
					direction_control_o <= "11";
				end if;
			end if;
			
		end if;
	end process;
end;