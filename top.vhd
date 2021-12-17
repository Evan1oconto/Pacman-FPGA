library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
	port(
		--tmp : in std_logic;
		ref_clk_i : in std_logic;
		
		controller_data_i : in std_logic;
		controller_latch_o : out std_logic;
		controller_clk_o : out std_logic;
		
		HSYNC_o : out std_logic;
		VSYNC_o : out std_logic;
		color_o : out std_logic_vector(5 downto 0);
		pll_pinout_o : out std_logic;
		
		--NESclk_o : out std_logic
		--NESinput_o : out std_logic
		debug_signal_o : out std_logic
	);
end top;
 
architecture struct of top is

	component PLLOSC is
		port(
			ref_clk_i   : in std_logic; -- input clock
			rst_n_i     : in std_logic; -- reset (active low)
			outcore_o   : out std_logic; -- output to pins
			outglobal_o : out std_logic -- output for clock network
		);
	end component;
	
	component vga is
		port(
			clk_i : in std_logic;
			HSYNC_o : out std_logic;
			VSYNC_o : out std_logic;
			col_o : out unsigned(9 downto 0);
			row_o : out unsigned(9 downto 0);
			valid_o : out std_logic
		);
	end component;
	
	component pattern_generator is
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
	end component;
	
	component NEScontroller is
		port(
			controller_data_i : in std_logic;
			controller_clk_i : in std_logic; -- NESclk
			
			controller_latch_o : out std_logic;
			controller_clk_o : out std_logic;
			input_register_o : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal clk : std_logic := '1'; -- 25MHz clk
	signal pll_out : std_logic;
	
	signal col : unsigned(9 downto 0);
	signal row : unsigned(9 downto 0);
	signal valid_pixel : std_logic;
	
	signal NEScounter : unsigned(7 downto 0);
	signal NESclk : std_logic;
	signal input_register : std_logic_vector(7 downto 0) := (others => '0');
	
begin
	osc : PLLOSC port map(ref_clk_i, '1', pll_pinout_o, clk);
	display : vga port map(clk, HSYNC_o, VSYNC_o, col, row, valid_pixel);
	render : pattern_generator port map(clk, col, row, valid_pixel, VSYNC_o, input_register, color_o, debug_signal_o);
	controller : NEScontroller port map(controller_data_i, NESclk, controller_latch_o, controller_clk_o, input_register);
	
	process (clk) is
	begin
		if rising_edge(clk) then
			NEScounter <= NEScounter + '1';
		end if;
	end process;
	NESclk <= NEScounter(7);
	--HSYNC_o <= NEScounter(7);
	
	--NESclk_o <= NEScounter(7);
	--NESinput_o <= input_register(7);
end;