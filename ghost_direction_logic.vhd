library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ghost_direction_logic is
	port(
		clk_i : in std_logic;
		reset_i : in std_logic;
		ghost_xpos_i : in unsigned(9 downto 0);
		ghost_ypos_i : in unsigned(9 downto 0);
		can_move_i : in std_logic_vector(3 downto 0);
		pacman_xpos_i : in unsigned(9 downto 0);
		pacman_ypos_i : in unsigned(9 downto 0);
		direction_control_o : out std_logic_vector(1 downto 0);
		debug_signal_o : out std_logic
	);
end ghost_direction_logic;

architecture synth of ghost_direction_logic is
	
	signal prev_direction : std_logic_vector(1 downto 0);
	signal prev_can_move : std_logic_vector(3 downto 0);
	
	
begin

	-- happens at start of new frame
	process(clk_i) is
		variable cooldown_counter : unsigned(3 downto 0) := (others => '0');
		variable h_dist : signed(9 downto 0) := (others => '0');
		variable v_dist : signed(9 downto 0) := (others => '0');
		--variable new_direction : std_logic_vector(1 downto 0) := "00";
		variable prefer_horizontal : boolean := false;
		variable prefer_left : boolean := false;
		variable prefer_up : boolean := false;
	begin
		if rising_edge(clk_i) then
			if reset_i then
				direction_control_o <= "10";
			else
				prev_can_move <= can_move_i;
				
				h_dist := signed(pacman_xpos_i) - signed(ghost_xpos_i);
				v_dist := signed(pacman_ypos_i) - signed(ghost_ypos_i);
				
				prefer_horizontal := true when (abs(h_dist) > abs(v_dist)) else false;
				
				prefer_left := true when (h_dist <= 0) else false;
				prefer_up   := true when (v_dist <= 0) else false;
				
				debug_signal_o <= '1' when direction_control_o = "01" else '0';
				
				if cooldown_counter < 4x"A" then
					cooldown_counter := cooldown_counter + 1;
				end if;
				
				
				
				if (can_move_i /= prev_can_move and cooldown_counter = 4x"A") then
					cooldown_counter := 4x"0";
					--prev_direction <= direction_control_o;
					--------------------------------------------------------
					if    direction_control_o = "00" then -- was going up, cannot reverse down
					
						-- want to continue
						if not prefer_horizontal and prefer_up then
							if can_move_i(0) = '1' then
								direction_control_o <= "00";
							else
								if prefer_left then
									if can_move_i(2) = '1' then
										direction_control_o <= "10";
									else
										direction_control_o <= "11";
									end if;
								else
									if can_move_i(3) = '1' then
										direction_control_o <= "11";
									else
										direction_control_o <= "10";
									end if;
								end if;
							end if;
						
						-- want to reverse
						elsif not prefer_horizontal and not prefer_up then
							if can_move_i(2) = '0' and can_move_i(3) = '0' then
								direction_control_o <= "00";
							elsif prefer_left then
								if can_move_i(2) = '1' then
									direction_control_o <= "10";
								else
									direction_control_o <= "11";
								end if;
							else
								if can_move_i(3) = '1' then
									direction_control_o <= "11";
								else
									direction_control_o <= "10";
								end if;
							end if;
						
						-- want to turn counter-clockwise (moving left)
						elsif prefer_horizontal and prefer_left then
							if can_move_i(2) = '1' then
								direction_control_o <= "10";
							elsif can_move_i(0) = '1' then
								direction_control_o <= "00";
							else -- must move right
								direction_control_o <= "11";
							end if;
						
						else -- prefer_horizontal and not prefer_left (want to turn clockwise) (moving right)
							if can_move_i(3) = '1' then
								direction_control_o <= "11";
							elsif can_move_i(0) = '1' then
								direction_control_o <= "00";
							else -- must move left
								direction_control_o <= "10";
							end if;
						end if;
					--------------------------------------------------------	
					elsif direction_control_o = "01" then -- was going down, cannot reverse up
					
						-- want to continue
						if not prefer_horizontal and not prefer_up then
							if can_move_i(1) = '1' then
								direction_control_o <= "01";
							else
								if prefer_left then
									if can_move_i(2) = '1' then
										direction_control_o <= "10";
									else
										direction_control_o <= "11";
									end if;
								else
									if can_move_i(3) = '1' then
										direction_control_o <= "11";
									else
										direction_control_o <= "10";
									end if;
								end if;
							end if;
							
						-- want to reverse
						elsif not prefer_horizontal and prefer_up then
							if can_move_i(2) = '0' and can_move_i(3) = '0' then
								direction_control_o <= "01";
							elsif prefer_left then
								if can_move_i(2) = '1' then
									direction_control_o <= "10";
								else
									direction_control_o <= "11";
								end if;
							else
								if can_move_i(3) = '1' then
									direction_control_o <= "11";
								else
									direction_control_o <= "10";
								end if;
							end if;
							
						-- want to turn counter-clockwise (moving right)
						elsif prefer_horizontal and not prefer_left then
							if can_move_i(3) = '1' then
								direction_control_o <= "11";
							elsif can_move_i(1) = '1' then
								direction_control_o <= "01";
							else -- must move left
								direction_control_o <= "10";
							end if;
							
						else -- prefer_horizontal and prefer_left (want to turn clockwise) (moving left)
							if can_move_i(2) = '1' then
								direction_control_o <= "10";
							elsif can_move_i(1) = '1' then
								direction_control_o <= "01";
							else -- must move right
								direction_control_o <= "11";
							end if;
						end if;
						
					--------------------------------------------------------------------				
					elsif direction_control_o = "10" then -- was going left, cannot reverse right
					
						-- want to continue
						if prefer_horizontal and prefer_left then
							if can_move_i(2) = '1' then
								direction_control_o <= "10";
							else
								if prefer_up then
									if can_move_i(0) = '1' then
										direction_control_o <= "00";
									else
										direction_control_o <= "01";
									end if;
								else
									if can_move_i(1) = '1' then
										direction_control_o <= "01";
									else
										direction_control_o <= "00";
									end if;
								end if;
							end if;
						
						-- want to reverse
						elsif prefer_horizontal and not prefer_left then
							if can_move_i(0) = '0' and can_move_i(1) = '0' then
								direction_control_o <= "10";
							elsif prefer_up then
								if can_move_i(0) = '1' then
									direction_control_o <= "00";
								else
									direction_control_o <= "01";
								end if;
							else
								if can_move_i(1) = '1' then
									direction_control_o <= "01";
								else
									direction_control_o <= "00";
								end if;
							end if;
							
						-- want to turn counter-clockwise (moving down)
						elsif not prefer_horizontal and not prefer_up then
							if can_move_i(1) = '1' then
								direction_control_o <= "01";
							elsif can_move_i(2) = '1' then
								direction_control_o <= "10";
							else -- must move up
								direction_control_o <= "00";
							end if;
						
						
						else -- not prefer_horizontal and prefer_up (want to turn clockwise) (moving up)
							if can_move_i(0) = '1' then
								direction_control_o <= "00";
							elsif can_move_i(2) = '1' then
								direction_control_o <= "10";
							else -- must move down
								direction_control_o <= "01";
							end if;
						end if;
					--------------------------------------------------------------------
					------there might be a bug in this section -hannah dec 12-----------
					--------------------------------------------------------------------	
					elsif direction_control_o = "11" then -- was going right, cannot reverse left
					
						-- want to continue
						if prefer_horizontal and not prefer_left then
							if can_move_i(3) = '1' then
								direction_control_o <= "11";
							else
								if prefer_up then
									if can_move_i(0) = '1' then
										direction_control_o <= "00";
									else
										direction_control_o <= "01";
									end if;
								else
									if can_move_i(1) = '1' then
										direction_control_o <= "01";
									else
										direction_control_o <= "00";
									end if;
								end if;
							end if;
					
					
						-- want to reverse
						elsif prefer_horizontal and prefer_left then
							if can_move_i(0) = '0' and can_move_i(1) = '0' then
								direction_control_o <= "11";
							elsif prefer_up then
								if can_move_i(0) = '1' then
									direction_control_o <= "00";
								else
									direction_control_o <= "01";
								end if;
							else
								if can_move_i(1) = '1' then
									direction_control_o <= "01";
								else
									direction_control_o <= "00";
								end if;
							end if;
							
						-- want to turn counter-clockwise (moving up)
						elsif not prefer_horizontal and prefer_up then
							if can_move_i(0) = '1' then
								direction_control_o <= "00";
							elsif can_move_i(3) = '1' then
								direction_control_o <= "11";
							else -- must move down
								direction_control_o <= "01";
							end if;
							
						
						else -- not prefer_horizontal and not prefer_up (want to turn clockwise) (moving down)
							if can_move_i(1) = '1' then
								direction_control_o <= "01";
							elsif can_move_i(3) = '1' then
								direction_control_o <= "11";
							else -- must move down
								direction_control_o <= "00";                -----------------------------------------------**************
							end if;
						end if;
					else
						direction_control_o <= "10";
					end if; -- direction choice
				end if;		
			end if;
		--elsif rising_edge(clk_i) then
			--direction_control_o <= new_direction;
		end if;
	end process;
end;