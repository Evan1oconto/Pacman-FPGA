library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_generator is
	port(
		clk_i : in std_logic;
		col_i : in unsigned(9 downto 0);
		row_i : in unsigned(9 downto 0);
		valid_pixel_i : in std_logic;
		next_frame_i : in std_logic;
		input_register_i : in std_logic_vector(7 downto 0);
		color_o : out std_logic_vector(5 downto 0);
		debug_signal_o : out std_logic
	);
end pattern_generator;

architecture synth of pattern_generator is
	signal frame_num : unsigned(10 downto 0);
	signal pixel_curr_block : unsigned(10 downto 0);
	signal rom_out : std_logic;
	signal reset : std_logic;
	signal you_lose : std_logic := '0';
	signal you_win : std_logic := '0';
	---------------------------------------------------------------
	signal pacman_xpos : unsigned(9 downto 0);
	signal pacman_ypos : unsigned(9 downto 0);
	constant pacman_reset_xpos : unsigned (9 downto 0) := 10d"312";
	constant pacman_reset_ypos : unsigned (9 downto 0) := 10d"256";
	signal pacman_curr_block : unsigned(10 downto 0);
	signal pacman_direction_control : std_logic_vector(1 downto 0);
	signal pacman_can_move : std_logic_vector(3 downto 0);
	signal is_pacman_pixel : std_logic;
	signal pacman_color : std_logic_vector(5 downto 0);
	signal pacman_direction : std_logic_vector(1 downto 0);
	--signal pacman_lives : std_logic := '0';
	---------------------------------------------------------------
	signal blinky_xpos : unsigned(9 downto 0);
	signal blinky_ypos : unsigned(9 downto 0);
	constant blinky_reset_xpos : unsigned (9 downto 0) := 10d"312";
	constant blinky_reset_ypos : unsigned (9 downto 0) := 10d"160";
	signal blinky_direction_control : std_logic_vector(1 downto 0);
	signal blinky_can_move : std_logic_vector(3 downto 0);
	signal is_blinky_pixel : std_logic;
	signal blinky_color : std_logic_vector(5 downto 0);
	signal blinky_curr_block : unsigned(10 downto 0);
	signal blinky_xtarget :  unsigned(9 downto 0);
	signal blinky_ytarget :  unsigned(9 downto 0);
	
	signal inky_xpos : unsigned(9 downto 0);
	signal inky_ypos : unsigned(9 downto 0);
	constant inky_reset_xpos : unsigned (9 downto 0) := 10d"328";
	constant inky_reset_ypos : unsigned (9 downto 0) := 10d"160";
	signal inky_direction_control : std_logic_vector(1 downto 0);
	signal inky_can_move : std_logic_vector(3 downto 0);
	signal is_inky_pixel : std_logic;
	signal inky_color : std_logic_vector(5 downto 0);
	signal inky_curr_block : unsigned(10 downto 0);
	signal inky_xtarget :  unsigned(9 downto 0);
	signal inky_ytarget :  unsigned(9 downto 0);

	signal pinky_xpos : unsigned(9 downto 0);
	signal pinky_ypos : unsigned(9 downto 0);
	constant pinky_reset_xpos : unsigned (9 downto 0) := 10d"296";
	constant pinky_reset_ypos : unsigned (9 downto 0) := 10d"160";
	signal pinky_direction_control : std_logic_vector(1 downto 0);
	signal pinky_can_move : std_logic_vector(3 downto 0);
	signal is_pinky_pixel : std_logic;
	signal pinky_color : std_logic_vector(5 downto 0);
	signal pinky_curr_block : unsigned(10 downto 0);
	signal pinky_xtarget :  unsigned(9 downto 0);
	signal pinky_ytarget :  unsigned(9 downto 0);
	
	signal clyde_xpos : unsigned(9 downto 0);
	signal clyde_ypos : unsigned(9 downto 0);
	constant clyde_reset_xpos : unsigned (9 downto 0) := 10d"344";
	constant clyde_reset_ypos : unsigned (9 downto 0) := 10d"160";
	signal clyde_direction_control : std_logic_vector(1 downto 0);
	signal clyde_can_move : std_logic_vector(3 downto 0);
	signal is_clyde_pixel : std_logic;
	signal clyde_color : std_logic_vector(5 downto 0);
	signal clyde_curr_block : unsigned(10 downto 0);
	signal clyde_xtarget :  unsigned(9 downto 0);
	signal clyde_ytarget :  unsigned(9 downto 0);
	
	signal r_addr : std_logic_vector(10 downto 0);
	signal r_data : std_logic;
	signal w_addr : std_logic_vector(10 downto 0);
	signal w_data : std_logic;
	signal w_enable : std_logic;
	signal coin_init : std_logic := '0';
	signal coin_init_count : unsigned(10 downto 0);
	signal coin_reset : std_logic := '0';
	signal coin_count : unsigned(8 downto 0);
	signal coins_left : std_logic;
	signal coin_out_changing : std_logic;
	
	signal intermed11 : unsigned(10 downto 0);
	signal intermed12 : unsigned(10 downto 0);
	signal intermed13 : unsigned(21 downto 0);
	signal intermed14 : unsigned(10 downto 0);
	signal my_debug : std_logic_vector(1 downto 0);
	
	signal intermed15 : unsigned(10 downto 0);
	signal intermed16 : unsigned(10 downto 0);
	signal intermed17 : unsigned(21 downto 0);
	signal intermed18 : unsigned(10 downto 0);
	
	signal intermed25 : unsigned(10 downto 0);
	signal intermed26 : unsigned(10 downto 0);
	signal intermed27 : unsigned(21 downto 0);
	signal intermed28 : unsigned(10 downto 0);
	
	signal intermed35 : unsigned(10 downto 0);
	signal intermed36 : unsigned(10 downto 0);
	signal intermed37 : unsigned(21 downto 0);
	signal intermed38 : unsigned(10 downto 0);

	signal intermed45 : unsigned(10 downto 0);
	signal intermed46 : unsigned(10 downto 0);
	signal intermed47 : unsigned(21 downto 0);
	signal intermed48 : unsigned(10 downto 0);
	
	signal debug_2 : std_logic;
	signal debug_3 : std_logic;
	signal debug_4 : std_logic;
	
	signal blinky_sprite_rom_out : std_logic;
	signal blinky_pixel : unsigned(7 downto 0);
	signal inky_sprite_rom_out : std_logic;
	signal inky_pixel : unsigned(7 downto 0);
	signal pinky_sprite_rom_out : std_logic;
	signal pinky_pixel : unsigned(7 downto 0);
	signal clyde_sprite_rom_out : std_logic;
	signal clyde_pixel : unsigned(7 downto 0);
	
	signal blinky_col : std_logic_vector(5 downto 0);
	signal inky_col : std_logic_vector(5 downto 0);
	signal pinky_col : std_logic_vector(5 downto 0);
	signal clyde_col : std_logic_vector(5 downto 0);
	
	signal pacman_sprite_up_rom_out : std_logic;
	signal pacman_sprite_right_rom_out : std_logic;
	signal pacman_sprite_left_rom_out : std_logic;
	signal pacman_sprite_down_rom_out : std_logic;
	signal pacman_pixel: unsigned(7 downto 0);
	signal pac_col : std_logic_vector(5 downto 0);

	
-----------------------------------------------------------------------------------
	
	component right_pacman_sprite_rom is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(7 downto 0);
			data : out std_logic
		);
	end component;
	
	component up_pacman_sprite_rom is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(7 downto 0);
			data : out std_logic
		);
	end component;
	
	component left_pacman_sprite_rom is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(7 downto 0);
			data : out std_logic
		);
	end component;
	
	component down_pacman_sprite_rom is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(7 downto 0);
			data : out std_logic
		);
	end component;
	

	
	component ghost_sprite is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(7 downto 0);
			data : out std_logic
		);
	end component;
	
	component pacman is
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
	end component;
	
	
	component ghost is
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
	end component;
	
	component pacman_direction_logic is
		port(
			clk_i : in std_logic;
			reset_i : in std_logic;
			input_register_i : in std_logic_vector(7 downto 0);
			direction_control_o : out std_logic_vector(1 downto 0)
		);
	end component;
	
	component ghost_direction_logic is
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
	end component;

	component board_map is
		port(
			clk: in std_logic;
			addr : in std_logic_vector(10 downto 0);
			data : out std_logic
		);
	end component;
	
	component coin_map is
	  port(
		clk : in std_logic;
		r_addr : in std_logic_vector(10 downto 0);
		r_data : out std_logic;
		w_addr : in std_logic_vector(10 downto 0);
		w_data : in std_logic;
		w_enable : in std_logic
	  );
	end component;

begin
	coinMap : coin_map port map(
		clk => clk_i,
		r_addr => r_addr,
		r_data => r_data,
		w_addr => w_addr,
		w_data => w_data,
		w_enable => w_enable
	  );

	my_pacman : pacman port map(
		clk_i               => clk_i,
		col_i               => col_i,
		row_i               => row_i,
		valid_pixel_i       => valid_pixel_i,
		is_pixel_wall_i     => rom_out,
		next_frame_i        => next_frame_i,
		direction_control_i => pacman_direction_control,
		reset_i             => reset,
		set_xpos_i          => pacman_reset_xpos,
		set_ypos_i          => pacman_reset_ypos,
		xpos_o              => pacman_xpos,
		ypos_o              => pacman_ypos,
		can_move_o          => pacman_can_move,
		is_actor_pixel_o    => is_pacman_pixel,
		curr_direction 		=> pacman_direction,
		color_o             => pacman_color
	);
	
	pacman_brain : pacman_direction_logic port map(
		clk_i => next_frame_i,
		reset_i => reset,
		input_register_i => input_register_i,
		direction_control_o => pacman_direction_control
	);
	-------------------------------------------------------
	blinky : ghost port map(
		clk_i               => clk_i,
		col_i               => col_i,
		row_i               => row_i,
		valid_pixel_i       => valid_pixel_i,
		is_pixel_wall_i     => rom_out,
		next_frame_i        => next_frame_i,
		direction_control_i => blinky_direction_control,
		reset_i             => reset,
		set_xpos_i          => blinky_reset_xpos,
		set_ypos_i          => blinky_reset_ypos,
		xpos_o              => blinky_xpos,
		ypos_o              => blinky_ypos,
		can_move_o          => blinky_can_move,
		is_actor_pixel_o    => is_blinky_pixel,
		debug				=> my_debug,
		color_o             => blinky_color
	);
	
	blinky_brain : ghost_direction_logic port map(
		clk_i               => clk_i,
		reset_i             => reset,
		ghost_xpos_i        => blinky_xpos,
		ghost_ypos_i        => blinky_ypos,
		can_move_i          => blinky_can_move,
		pacman_xpos_i       => blinky_xtarget,
		pacman_ypos_i       => blinky_ytarget,
		direction_control_o => blinky_direction_control,
		debug_signal_o => debug_signal_o
	);
	
	--------------------------------------------------------
	--inky_brain
	inky : ghost port map(
		clk_i               => clk_i,
		col_i               => col_i,
		row_i               => row_i,
		valid_pixel_i       => valid_pixel_i,
		is_pixel_wall_i     => rom_out,
		next_frame_i        => next_frame_i,
		direction_control_i => inky_direction_control,
		reset_i             => reset,
		set_xpos_i          => inky_reset_xpos,
		set_ypos_i          => inky_reset_ypos,
		xpos_o              => inky_xpos,
		ypos_o              => inky_ypos,
		can_move_o          => inky_can_move,
		is_actor_pixel_o    => is_inky_pixel,
		debug				=> my_debug,
		color_o             => inky_color
	);
	
	inky_brain : ghost_direction_logic port map(
		clk_i               => clk_i,
		reset_i             => reset,
		ghost_xpos_i        => inky_xpos,
		ghost_ypos_i        => inky_ypos,
		can_move_i          => inky_can_move,
		pacman_xpos_i       => inky_xtarget,
		pacman_ypos_i       => inky_ytarget,
		direction_control_o => inky_direction_control,
		debug_signal_o => debug_2
	);
	
	--------------------------------------------------------
	--pinky_brain
	pinky : ghost port map(
		clk_i               => clk_i,
		col_i               => col_i,
		row_i               => row_i,
		valid_pixel_i       => valid_pixel_i,
		is_pixel_wall_i     => rom_out,
		next_frame_i        => next_frame_i,
		direction_control_i => pinky_direction_control,
		reset_i             => reset,
		set_xpos_i          => pinky_reset_xpos,
		set_ypos_i          => pinky_reset_ypos,
		xpos_o              => pinky_xpos,
		ypos_o              => pinky_ypos,
		can_move_o          => pinky_can_move,
		is_actor_pixel_o    => is_pinky_pixel,
		debug				=> my_debug,
		color_o             => pinky_color
	);
	
	pinky_brain : ghost_direction_logic port map(
		clk_i               => clk_i,
		reset_i             => reset,
		ghost_xpos_i        => pinky_xpos,
		ghost_ypos_i        => pinky_ypos,
		can_move_i          => pinky_can_move,
		pacman_xpos_i       => pinky_xtarget,
		pacman_ypos_i       => pinky_ytarget,
		direction_control_o => pinky_direction_control,
		debug_signal_o => debug_3
	);
	--------------------------------------------------------
	--clyde_brain
	clyde : ghost port map(
		clk_i               => clk_i,
		col_i               => col_i,
		row_i               => row_i,
		valid_pixel_i       => valid_pixel_i,
		is_pixel_wall_i     => rom_out,
		next_frame_i        => next_frame_i,
		direction_control_i => clyde_direction_control,
		reset_i             => reset,
		set_xpos_i          => clyde_reset_xpos,
		set_ypos_i          => clyde_reset_ypos,
		xpos_o              => clyde_xpos,
		ypos_o              => clyde_ypos,
		can_move_o          => clyde_can_move,
		is_actor_pixel_o    => is_clyde_pixel,
		debug				=> my_debug,
		color_o             => clyde_color
	);

	clyde_brain : ghost_direction_logic port map(
		clk_i               => clk_i,
		reset_i             => reset,
		ghost_xpos_i        => clyde_xpos,
		ghost_ypos_i        => clyde_ypos,
		can_move_i          => clyde_can_move,
		pacman_xpos_i       => clyde_xtarget,
		pacman_ypos_i       => clyde_ytarget,
		direction_control_o => clyde_direction_control,
		debug_signal_o => debug_4
	);
	--------------------------------------------------------

	wall_map : board_map port map(
		clk  => clk_i,
		addr => std_logic_vector(pixel_curr_block),
		data => rom_out
	);
	
	--------------------------------------------------------
	blinky_sprite : ghost_sprite port map(
		clk  => clk_i,
		addr => std_logic_vector(blinky_pixel),
		data => blinky_sprite_rom_out
	);
	
	inky_sprite : ghost_sprite port map(
		clk  => clk_i,
		addr => std_logic_vector(inky_pixel),
		data => inky_sprite_rom_out
	);
	
	pinky_sprite : ghost_sprite port map(
		clk  => clk_i,
		addr => std_logic_vector(pinky_pixel),
		data => pinky_sprite_rom_out
	);
	
	clyde_sprite : ghost_sprite port map(
		clk  => clk_i,
		addr => std_logic_vector(clyde_pixel),
		data => clyde_sprite_rom_out
	);
--------------------------------------------------------
	pacman_right : right_pacman_sprite_rom port map(
		clk  => clk_i,
		addr => std_logic_vector(pacman_pixel),
		data => pacman_sprite_right_rom_out
	);
	
	pacman_up : up_pacman_sprite_rom port map(
		clk  => clk_i,
		addr => std_logic_vector(pacman_pixel),
		data => pacman_sprite_up_rom_out
	);
	
	pacman_left : left_pacman_sprite_rom port map (
		clk  => clk_i,
		addr => std_logic_vector(pacman_pixel),
		data => pacman_sprite_left_rom_out
	);
	
	pacman_down : down_pacman_sprite_rom port map (
		clk  => clk_i,
		addr => std_logic_vector(pacman_pixel),
		data => pacman_sprite_down_rom_out
	);
--------------------------------------------------------
	--converts x/y position to a block number
	intermed11 <= "00000" & pacman_xpos(9 downto 4);
	intermed12 <= ("00000" & pacman_ypos(9 downto 4));
	intermed13 <= "00000101000" * intermed12;
	intermed14 <=  intermed13(10 downto 0);
	pacman_curr_block <= intermed11 + intermed14;
	
	intermed15 <= "00000" & blinky_xpos(9 downto 4);
	intermed16 <= ("00000" & blinky_ypos(9 downto 4));
	intermed17 <= "00000101000" * intermed16;
	intermed18 <=  intermed17(10 downto 0);
	blinky_curr_block <= intermed15 + intermed18;

	intermed25 <= "00000" & inky_xpos(9 downto 4);
	intermed26 <= ("00000" & inky_ypos(9 downto 4));
	intermed27 <= "00000101000" * intermed26;
	intermed28 <=  intermed27(10 downto 0);
	inky_curr_block <= intermed25 + intermed28;
	
	intermed35 <= "00000" & pinky_xpos(9 downto 4);
	intermed36 <= ("00000" & pinky_ypos(9 downto 4));
	intermed37 <= "00000101000" * intermed36;
	intermed38 <=  intermed37(10 downto 0);
	pinky_curr_block <= intermed35 + intermed38;
	
	intermed45 <= "00000" & clyde_xpos(9 downto 4);
	intermed46 <= ("00000" & clyde_ypos(9 downto 4));
	intermed47 <= "00000101000" * intermed46;
	intermed48 <=  intermed47(10 downto 0);
	clyde_curr_block <= intermed45 + intermed48;
	
	--determines when ghosts should attack you	blinky_xtarget <= pacman_xpos when (frame_num(10) = '0') else "1001110000";
	blinky_ytarget <= pacman_ypos when (frame_num(10) = '0') else "0000000000";
	inky_xtarget <= pacman_xpos when (frame_num(10) = '1') else "0000000000";
	inky_ytarget <= pacman_ypos when (frame_num(10) = '1') else "0000000000";
	pinky_xtarget <= pacman_xpos when (frame_num(10) = '1') else "0000000000";
	pinky_ytarget <= pacman_ypos when (frame_num(10) = '1') else "0100101100";
	clyde_xtarget <= pacman_xpos when (frame_num(10) = '0') else "1001110000";
	clyde_ytarget <= pacman_ypos when (frame_num(10) = '0') else "0111011111";

	-- when controller signal direction; update next_direction
	-- when the direction is updated to Next_direction, set curr_direction to next_direction
	
	process (clk_i) is
	begin
		if (rising_edge(clk_i)) then
			--pacman_curr_block <= resize(pacman_xpos(9 downto 4) + (11d"40" * pacman_ypos(9 downto 4)),11);
			pixel_curr_block <= resize(col_i(9 downto 4) + (11d"40" * row_i(9 downto 4)),11);
			
			
		blinky_pixel <= ("0000" & (col_i(3 downto 0) - blinky_xpos(3 downto 0)))  + ((row_i(3 downto 0) - blinky_ypos(3 downto 0)) & "0010");
		blinky_col <= "110000" when (blinky_sprite_rom_out = '1') else "000000";
		
		inky_pixel <= ("0000" & (col_i(3 downto 0) - inky_xpos(3 downto 0)))  + ((row_i(3 downto 0) - inky_ypos(3 downto 0)) & "0010");
		inky_col <= "001100" when (inky_sprite_rom_out = '1') else "000000";
		
		pinky_pixel <= ("0000" & (col_i(3 downto 0) - pinky_xpos(3 downto 0)))  + ((row_i(3 downto 0) - pinky_ypos(3 downto 0)) & "0010");
		pinky_col <= "110011" when (pinky_sprite_rom_out = '1') else "000000";
		
		clyde_pixel <= ("0000" & (col_i(3 downto 0) - clyde_xpos(3 downto 0)))  + ((row_i(3 downto 0) - clyde_ypos(3 downto 0)) & "0010");
		clyde_col <= "111000" when (clyde_sprite_rom_out = '1') else "000000";
		
		pacman_pixel <= ("0000" & (col_i(3 downto 0) - pacman_xpos(3 downto 0)))  + ((row_i(3 downto 0) - pacman_ypos(3 downto 0)) & "0010");
		pac_col <= "111100" when (pacman_sprite_right_rom_out = '1' and pacman_direction = "11") else
					"111100" when (pacman_sprite_up_rom_out = '1' and pacman_direction = "00") else
					"111100" when (pacman_sprite_left_rom_out = '1' and pacman_direction = "10") else
					"111100" when (pacman_sprite_down_rom_out = '1' and pacman_direction = "01") else
					"000000";
			
			
		--COIN RAM:----------------------------------------
			coin_init_count <= "00000000000";
			if(coin_init = '0') then
				--coins_left <= '1';
				w_addr <= std_logic_vector(pixel_curr_block);
				w_enable <= '1';
				w_data <= '1' when rom_out = '0' else '0';
				if(pixel_curr_block = "10010101111") then
					coin_init <= '1';
				end if;
			elsif(input_register_i(4)) then
				coin_init <= '0';	
			else
				r_addr <= std_logic_vector(pixel_curr_block);
				--if (r_data = '1') then
					--coins_left <= '1';
				--elsif(pixel_curr_block = "0000000001") then
					--coins_left <= '0';
				--end if;
				w_enable <= '1';
				w_addr <= std_logic_vector(pacman_curr_block);
				w_data <= '0';
			end if;
			
			-----------------------------------------------------
			
			
			color_o <= "000000" when (valid_pixel_i = '0') else
					   "110000" when (you_lose) else
					   "001100" when (you_win) else
					   "000011" when (col_i < 10d"5") else
					   
					   	--DEBUG SIGNALS:
						--"110001" when (pixel_curr_block = 10d"41" and pacman_lives = '0') else
			           --"111100" when (pixel_curr_block = 10d"41" and pacman_can_move(0) = '1') else
					   --"111100" when (pixel_curr_block = 10d"42" and pacman_can_move(1) = '1') else
					   --"111100" when (pixel_curr_block = 10d"43" and pacman_can_move(2) = '1') else
					   --"111100" when (pixel_curr_block = 10d"44" and pacman_can_move(3) = '1') else
					   --"110000" when (pixel_curr_block = 10d"81" and blinky_can_move(0) = '1') else
					   --"110000" when (pixel_curr_block = 10d"82" and blinky_can_move(1) = '1') else
					   --"110000" when (pixel_curr_block = 10d"83" and blinky_can_move(2) = '1') else
					   --"110000" when (pixel_curr_block = 10d"84" and blinky_can_move(3) = '1') else
					   --"110000" when (pixel_curr_block = 10d"85" and blinky_direction_control(1) = '1') else
					   --"110000" when (pixel_curr_block = 10d"86" and blinky_direction_control(0) = '1') else
					   --"111000" when (pixel_curr_block = 10d"87" and my_debug(1) = '1') else
					   --"111000" when (pixel_curr_block = 10d"87" and my_debug(0) = '1') else
					   --"111100" when (pixel_curr_block = 10d"201" and pacman_direction_control = "00") else
					   --"110000" when (pixel_curr_block = 10d"202" and pacman_direction_control = "01") else
					   --"110011" when (pixel_curr_block = 10d"203" and pacman_direction_control = "10") else
					   --"001100" when (pixel_curr_block = 10d"204" and pacman_direction_control = "11") else
					   
					   pac_col when (is_pacman_pixel) else -- 10d"320"
					   blinky_col when (is_blinky_pixel) else
					   inky_col when (is_inky_pixel) else
					   pinky_col when (is_pinky_pixel) else
					   clyde_col when (is_clyde_pixel) else
					   "111111" when (r_data = '1' and (row_i(3 downto 0) > "0110") and  (row_i(3 downto 0) < "1010") and (col_i(3 downto 0) > "0110") and  (col_i(3 downto 0) < "001010")) else

					   "000011" when (rom_out = '1') else
					   "000000";
		end if;
	end process;

	-- happens at start of new frame
	process(next_frame_i) is
	begin
		if rising_edge(next_frame_i) then
			--coin_out_changing <= '0';
			frame_num <= frame_num + 1;
			
			if  input_register_i(4) then -- START to reset
				reset <= '1';
				you_lose <= '0';
				--pacman_lives <= '0';
			elsif (blinky_curr_block = pacman_curr_block or inky_curr_block = pacman_curr_block or pinky_curr_block = pacman_curr_block or clyde_curr_block = pacman_curr_block) then
				--pacman_lives <= not pacman_lives;
				you_lose <= '1';  --when pacman_lives = '1' else '0';
			--elsif (coins_left = '0') then
				--you_win <= '1';
			else
				reset <= '0';
			end if;
			
			
		end if;
		
	end process;
	
end;