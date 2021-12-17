library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ghost is
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
		debug : out std_logic_vector(1 downto 0);
		color_o : out std_logic_vector(5 downto 0)
	);
end ghost;

architecture synth of ghost is
	signal curr_direction : std_logic_vector(1 downto 0) := 2b"10"; -- left
	signal next_direction : std_logic_vector(1 downto 0) := 2b"10"; -- left
	
	signal up_collisions : std_logic_vector(7 downto 0);
	signal down_collisions : std_logic_vector(7 downto 0);
	signal left_collisions : std_logic_vector(7 downto 0);
	signal right_collisions : std_logic_vector(7 downto 0);
	
	signal up_can_move : std_logic_vector(3 downto 0);
	signal down_can_move : std_logic_vector(3 downto 0);
	signal left_can_move : std_logic_vector(3 downto 0);
	signal right_can_move : std_logic_vector(3 downto 0);
	
begin
	is_actor_pixel_o <= '1' when ((col_i > xpos_o) and (col_i < xpos_o + 16) and (row_i > ypos_o) and (row_i < ypos_o + 16)) else '0';
						  
	process (clk_i) is
	begin
		if (rising_edge(clk_i)) then
		--because it takes an entire frame to calculate collision info, we need to calculate collision info for all 4 possible movement directions
		--This means that we are doing 4 calculations and throwing out 3 of them, but it is still better than creating another board map ROM
			up_collisions(0) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o -  2)) else up_collisions(0); -- top left
			up_collisions(1) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o -  2)) else up_collisions(1); -- top right
			up_collisions(2) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o + 15)) else up_collisions(2); -- bottom right
			up_collisions(3) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o + 15)) else up_collisions(3); -- bottom left
			up_collisions(4) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o + 14)) else up_collisions(4); -- left bottom
			up_collisions(5) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o -  1)) else up_collisions(5); -- left top
			up_collisions(6) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o -  1)) else up_collisions(6); -- right top
			up_collisions(7) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o + 14)) else up_collisions(7); -- right bottom
			
			down_collisions(0) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o )) else down_collisions(0); -- top left
			down_collisions(1) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o)) else down_collisions(1); -- top right
			down_collisions(2) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o + 17)) else down_collisions(2); -- bottom right
			down_collisions(3) <= is_pixel_wall_i when (col_i = (xpos_o     ) and row_i = (ypos_o + 17)) else down_collisions(3); -- bottom left
			down_collisions(4) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o + 16)) else down_collisions(4); -- left bottom
			down_collisions(5) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o  + 1)) else down_collisions(5); -- left top
			down_collisions(6) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o  + 1)) else down_collisions(6); -- right top
			down_collisions(7) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o + 16)) else down_collisions(7); -- right bottom
						  
			left_collisions(0) <= is_pixel_wall_i when (col_i = (xpos_o -  1) and row_i = (ypos_o -  1)) else left_collisions(0); -- top left
			left_collisions(1) <= is_pixel_wall_i when (col_i = (xpos_o + 14) and row_i = (ypos_o -  1)) else left_collisions(1); -- top right
			left_collisions(2) <= is_pixel_wall_i when (col_i = (xpos_o + 14) and row_i = (ypos_o + 16)) else left_collisions(2); -- bottom right
			left_collisions(3) <= is_pixel_wall_i when (col_i = (xpos_o  - 1) and row_i = (ypos_o + 16)) else left_collisions(3); -- bottom left
			left_collisions(4) <= is_pixel_wall_i when (col_i = (xpos_o -  2) and row_i = (ypos_o + 15)) else left_collisions(4); -- left bottom
			left_collisions(5) <= is_pixel_wall_i when (col_i = (xpos_o -  2) and row_i = (ypos_o     )) else left_collisions(5); -- left top
			left_collisions(6) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o     )) else left_collisions(6); -- right top
			left_collisions(7) <= is_pixel_wall_i when (col_i = (xpos_o + 15) and row_i = (ypos_o + 15)) else left_collisions(7); -- right bottom
						  
			right_collisions(0) <= is_pixel_wall_i when (col_i = (xpos_o + 1) and row_i = (ypos_o -  1)) else right_collisions(0); -- top left
			right_collisions(1) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o -  1)) else right_collisions(1); -- top right
			right_collisions(2) <= is_pixel_wall_i when (col_i = (xpos_o + 16) and row_i = (ypos_o + 16)) else right_collisions(2); -- bottom right
			right_collisions(3) <= is_pixel_wall_i when (col_i = (xpos_o + 1) and row_i = (ypos_o + 16)) else right_collisions(3); -- bottom left
			right_collisions(4) <= is_pixel_wall_i when (col_i = (xpos_o    ) and row_i = (ypos_o + 15)) else right_collisions(4); -- left bottom
			right_collisions(5) <= is_pixel_wall_i when (col_i = (xpos_o    ) and row_i = (ypos_o     )) else right_collisions(5); -- left top
			right_collisions(6) <= is_pixel_wall_i when (col_i = (xpos_o + 17) and row_i = (ypos_o     )) else right_collisions(6); -- right top
			right_collisions(7) <= is_pixel_wall_i when (col_i = (xpos_o + 17) and row_i = (ypos_o + 15)) else right_collisions(7); -- right bottom
			
			up_can_move <= (up_collisions(7) nor up_collisions(6)) & -- right
				          (up_collisions(5) nor up_collisions(4)) & -- left
				          (up_collisions(3) nor up_collisions(2)) & -- bottom
			              (up_collisions(1) nor up_collisions(0));  -- top			
			down_can_move <= (down_collisions(7) nor down_collisions(6)) & -- right
				          (down_collisions(5) nor down_collisions(4)) & -- left
				          (down_collisions(3) nor down_collisions(2)) & -- bottom
			              (down_collisions(1) nor down_collisions(0));  -- top			
			left_can_move <= (left_collisions(7) nor left_collisions(6)) & -- right
				          (left_collisions(5) nor left_collisions(4)) & -- left
				          (left_collisions(3) nor left_collisions(2)) & -- bottom
			              (left_collisions(1) nor left_collisions(0));  -- top
			right_can_move <= (right_collisions(7) nor right_collisions(6)) & -- right
				          (right_collisions(5) nor right_collisions(4)) & -- left
				          (right_collisions(3) nor right_collisions(2)) & -- bottom
			              (right_collisions(1) nor right_collisions(0));  -- top
		end if;
	end process;
	
	
	
	
	
	
	--update sprite position and select which pre-calculated collision map to feed into the ghost's brain
	process(next_frame_i) is
	begin
		
		if rising_edge(next_frame_i) then
			if (reset_i) then
				xpos_o <= set_xpos_i;
				ypos_o <= set_ypos_i;
				can_move_o <= "1100";
			else
				--next_direction <= direction_control_i;

				if  xpos_o = 10d"98" then
					xpos_o <= 10d"527";
					can_move_o <= "1100";
				elsif xpos_o = 10d"528" then
					xpos_o <= 10d"99";
					can_move_o <= "1100";
				
				elsif (direction_control_i = "00" and can_move_o(0) = '1') then -- up
					ypos_o <= ypos_o - '1';
					curr_direction <= direction_control_i;
					can_move_o <= up_can_move;
				elsif (direction_control_i = "01" and can_move_o(1) = '1') then -- down
					ypos_o <= ypos_o + '1';
					curr_direction <= direction_control_i;
					can_move_o <= down_can_move;
				elsif (direction_control_i = "10" and can_move_o(2) = '1') then -- left
					xpos_o <= xpos_o - '1';
					curr_direction <= direction_control_i;
					can_move_o <= left_can_move;
				elsif (direction_control_i = "11" and can_move_o(3) = '1') then -- right
					xpos_o <= xpos_o + '1';
					curr_direction <= direction_control_i;
					can_move_o <= right_can_move;					
				------------------------------------------------------------------------------
				elsif (curr_direction = "00" and can_move_o(0) = '1') then -- up
					ypos_o <= ypos_o - '1';
					can_move_o <= up_can_move;
				elsif (curr_direction = "01" and can_move_o(1) = '1') then -- down
					ypos_o <= ypos_o + '1';
					can_move_o <= down_can_move;
				elsif (curr_direction = "10" and can_move_o(2) = '1') then -- left
					xpos_o <= xpos_o - '1';
					can_move_o <= left_can_move;
				elsif (curr_direction = "11" and can_move_o(3) = '1') then -- right
					xpos_o <= xpos_o + '1';
					can_move_o <= right_can_move;
				end if;
			end if;
		end if;
	end process;


end;