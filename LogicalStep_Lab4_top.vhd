
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
		clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
		rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
		pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
		sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
		leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
		seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
		seg7_char1  : out	std_logic;							-- seg7 digi selectors
		seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
          clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT				: out	std_logic_vector(6 downto 0);
			 DIG2				: out	std_logic;
			 DIG1				: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
         clkin      		: in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin					: in std_logic;
			rst_n					: in std_logic;
			rst_n_filtered		: out std_logic;
			pb_n					: in  std_logic_vector (3 downto 0);
			pb_n_filtered		: out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n					: in  std_logic;
			rst				   : out	std_logic;							 
			pb_n_filtered	   : in  std_logic_vector (3 downto 0);
			pb						: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
   end component; 
  component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;

component State_Machine port (
      clk			: in std_logic;
		reset			: in std_logic;
		clk_enable	: in std_logic;
		blink_sig	: in std_logic;
		
		NS_walk_req	: in std_logic;
		EW_walk_req : in std_logic;
		
		
		NS_reg_clear	: out std_logic;
		EW_reg_clear	: out std_logic;
		
		NS_walk		: out std_logic;
		EW_walk		: out std_logic;
		
		NS_green		: out std_logic;
		NS_yellow	: out std_logic;
		NS_red		: out std_logic;
		
		EW_green		: out std_logic;
		EW_yellow	: out std_logic;
		EW_red		: out std_logic;
		State_Number : out std_logic_vector(3 downto 0);
		state_debug : out std_logic_vector(3 downto 0)
        );
    end component; 
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode										: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			: std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	SIGNAL synch_out_EW, synch_out_NS				: std_logic; 
	SIGNAL clk_sig        								: std_logic;
   SIGNAL reset_sig      								: std_logic;
   SIGNAL clk_enable_sig 								: std_logic;
    
   SIGNAL NS_walk_sig   								: std_logic;
   SIGNAL EW_walk_sig   								: std_logic;
		
   SIGNAL NS_green_sig   								: std_logic;
   SIGNAL NS_yellow_sig 							 	: std_logic;
   SIGNAL NS_red_sig     								: std_logic;
    
   SIGNAL EW_green_sig   								: std_logic;
   SIGNAL EW_yellow_sig  								: std_logic;
   SIGNAL EW_red_sig     								: std_logic;
	
	SIGNAL NS_crossing_display 						: std_logic_vector(6 downto 0);
	SIGNAL EW_crossing_display							: std_logic_vector(6 downto 0);
	SIGNAL state_debug_sig 								: std_logic_vector(3 downto 0);
	SIGNAL NS_holding_register							: std_logic;
	SIGNAL EW_holding_register 						: std_logic;
	SIGNAL NS_register_clr								: std_logic;
	SIGNAL EW_register_clr								: std_logic;
	SIGNAL State_Number									: std_logic_vector(3 downto 0);
	
BEGIN
----------------------------------------------------------------------------------------------------
INST0: pb_filters					port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters				port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer     		port map (clkin_50,'0', rst, synch_rst);	
INST3: clock_generator 			port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

synch_EW: synchronizer 			port map (clkin_50,synch_rst, pb(1), synch_out_EW);
Synch_NS: synchronizer 			port map (clkin_50,synch_rst, pb(0), synch_out_NS);

holder_EW: holding_register 	port map	(clkin_50,synch_rst, EW_register_clr, synch_out_EW, EW_holding_register);
holder_NS: holding_register 	port map	(clkin_50,synch_rst, NS_register_clr, synch_out_NS, NS_holding_register);

State_Machine_inst: State_Machine	port map (clkin_50, synch_rst, sm_clken, blink_sig, NS_holding_register, EW_holding_register, NS_register_clr, EW_register_clr, NS_walk_sig, EW_walk_sig, NS_green_sig, NS_yellow_sig, 
NS_red_sig, EW_green_sig, EW_yellow_sig, EW_red_sig, State_Number(3 downto 0), state_debug_sig(3 downto 0));

seg7_mux_inst: segment7_mux port map (clkin_50, NS_crossing_display, EW_crossing_display, seg7_data, seg7_char2, seg7_char1);

NS_crossing_display <= NS_yellow_sig & '0' & '0' & NS_green_sig & '0' & '0' & NS_red_sig;

EW_crossing_display <= EW_yellow_sig & '0' & '0' & EW_green_sig & '0' & '0' & EW_red_sig;



leds(3) <= EW_holding_register;
leds(1) <= NS_holding_register;


leds(2) <= EW_walk_sig;
leds(0) <= NS_walk_sig;
leds(7 downto 4) <= State_Number(3 downto 0);
END SimpleCircuit;
