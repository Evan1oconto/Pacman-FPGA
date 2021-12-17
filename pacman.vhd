library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pacman is
	port(
		clk_i : in std_logic;
		col_i : in unsigned(9 downto 0);
		row_i : in unsigned(9 downto 0);
		valid_pixel_i : in std_logic;
		is_pixel_wall_i : in std_logic;
		next_frame_i : in std_logic;
		direction_control_i : in std_logic_vector(1 downto 0);
		reset_i : in std_logic;
		set_xpos_i : in unsigned (9 downto 0);
		set_ypos_i : in unsigned (9 downto 0);
		xpos_o : out unsigned (9 downto 0);
		ypos_o : out unsigned (9 downto 0);
		can_move_o : out std_logic_vector(3 downto 0);
		is_actor_pixel_o : out std_logic;
		curr_direction : out std_logic_vector(1 downto 0);
		color_o : out std_logic_vector(5 downto 0)
	);
end pacman;

architecture synth of pacman is

	signal next_direction : std_logic_vector(1 downto 0) := 2b"10"; -- left
	signal collisions : std_logic_vector(7 downto 0);

begin

	is_actor_pixel_o <= '1' when ((col_i > xpos_o) and (col_i < xpos_o + 16) and (row_i > ypos_o) and (row_i < ypos_o + 16)) else '0';
						  
	process (clk_i) is
	begin
		if (rising_edge(clk_i)) then
			collisions(0) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o -  1)) else collisions(0); -- top left
			collisions(1) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o -  1)) else collisions(1); -- top right
			collisions(2) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o + 16)) else collisions(2); -- bottom right
			collisions(3) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o + 16)) else collisions(3); -- bottom left
			collisions(4) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o + 15)) else collisions(4); -- left bottom
			collisions(5) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o     )) else collisions(5); -- left top
			collisions(6) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o     )) else collisions(6); -- right top
			collisions(7) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o + 15)) else collisions(7); -- right bottom
			
			can_move_o <= (collisions(7) nor collisions(6)) & -- right
				          (collisions(5) nor collisions(4)) & -- left
				          (collisions(3) nor collisions(2)) & -- bottom
			              (collisions(1) nor collisions(0));  -- top
			
		end if;
	end process;
	
	process(next_frame_i) is
	begin
		
		if rising_edge(next_frame_i) then
			if (reset_i) then
				xpos_o <= set_xpos_i;
				ypos_o <= set_ypos_i;
			else
				--next_direction <= direction_control_i;
				
				if    xpos_o = 10d"98" then
					xpos_o <= 10d"527";
				elsif xpos_o = 10d"528" then
					xpos_o <= 10d"99";
				elsif (direction_control_i = "00" and can_move_o(0) = '1') then -- up
					ypos_o <= ypos_o - '1';
					curr_direction <= direction_control_i;
				elsif (direction_control_i = "01" and can_move_o(1) = '1') then -- down
					ypos_o <= ypos_o + '1';
					curr_direction <= direction_control_i;
				elsif (direction_control_i = "10" and can_move_o(2) = '1') then -- left
					xpos_o <= xpos_o - '1';
					curr_direction <= direction_control_i;
				elsif (direction_control_i = "11" and can_move_o(3) = '1') then -- right
					xpos_o <= xpos_o + '1';
					curr_direction <= direction_control_i;			
				------------------------------------------------------------------------------
				elsif (curr_direction = "00" and can_move_o(0) = '1') then -- up
					ypos_o <= ypos_o - '1';
				elsif (curr_direction = "01" and can_move_o(1) = '1') then -- down
					ypos_o <= ypos_o + '1';
				elsif (curr_direction = "10" and can_move_o(2) = '1') then -- left
					xpos_o <= xpos_o - '1';
				elsif (curr_direction = "11" and can_move_o(3) = '1') then -- right
					xpos_o <= xpos_o + '1';
				end if;
			end if;
		end if;
	end process;
end;