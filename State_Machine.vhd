	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
	entity State_Machine is port
	(
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
	end entity;
	 
	
	architecture cir of State_Machine is
	 
	type STATE_NAMES is (S0, S1, S2, S3, S4, S5, S6, S7, s8, s9, s10, s11, s12, s13, s14, s15);   
	
	 
	signal current_state, next_state	:  STATE_NAMES;
	signal state_debug_int           : std_logic_vector(3 downto 0);
	
	begin
	 
	set_state_out: process(clk)
		begin
			if (rising_edge(clk)) then
				if (reset = '1') then
					current_state <= s0;
				elsif (clk_enable ='1') then
					current_state <= next_state;
				end if;
			end if;
		end process; 
				
	change_state: process(current_state)
    begin
        case current_state is
            when S0 =>
                if (EW_walk_req = '1' and NS_walk_req = '0') then
                    next_state <= S6;
                else
                    next_state <= S1;
                end if;
            when S1 =>
                if (EW_walk_req = '1' and NS_walk_req = '0') then
                    next_state <= S6;
                else
                    next_state <= S2;
                end if;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S7;
            when S7 =>
                next_state <= S8;
            when S8 =>
                if (EW_walk_req = '0' and NS_walk_req = '1') then
                    next_state <= S14;
                else
                    next_state <= S9;
                end if;
            when S9 =>
                if (EW_walk_req = '0' and NS_walk_req = '1') then
                    next_state <= S14;
                else
                    next_state <= S10;
                end if;
            when S10 =>
                next_state <= S11;
            when S11 =>
                next_state <= S12;
            when S12 =>
                next_state <= S13;
            when S13 =>
                next_state <= S14;
            when S14 =>
                next_state <= S15;
            when S15 =>
                next_state <= S0;
        end case;
    end process;
	
	set_output_lights: process(current_state)
		begin
			case current_state is 
				when s0|s1 => 
					
					NS_walk		<= '0';
					EW_walk		<= '0';
					
					NS_reg_clear <= '0';
					NS_green		<= blink_sig;
					NS_yellow	<= '0';
					NS_red		<= '0';
		
					EW_reg_clear <= '0';
					EW_green		<= '0';
					EW_yellow	<= '0';
					EW_red		<= '1';
					 state_debug_int <= "0000";
				when s2 | s3 | s4 | s5 => 
					NS_walk		<= '1';
					EW_walk		<= '0';
		
					NS_reg_clear <= '0';
					NS_green		<= '1';
					NS_yellow	<= '0';
					NS_red		<= '0';
		
					EW_reg_clear <= '0';
					EW_green		<= '0';
					EW_yellow	<= '0';
					EW_red		<= '1';
					state_debug_int <= "0001";
				when s6 | s7 => 
					NS_walk		<= '0';
					EW_walk		<= '0';
					
					NS_reg_clear <= '1';
					NS_green		<= '0';
					NS_yellow	<= '1';
					NS_red		<= '0';
		
					EW_reg_clear <= '0';
					EW_green		<= '0';
					EW_yellow	<= '0';
					EW_red		<= '1';
					state_debug_int <= "0010";
				when s8 | s9 => 
					NS_walk		<= '0';
					EW_walk		<= '0';
		
					NS_reg_clear <= '0';
					NS_green		<= '0';
					NS_yellow	<= '0';
					NS_red		<= '1';
		
					EW_reg_clear <= '0';
					EW_green		<= blink_sig;
					EW_yellow	<= '0';
					EW_red		<= '0';
					state_debug_int <= "0011";
				when s10 | s11 | s12 | s13 => 
					NS_walk		<= '0';
					EW_walk		<= '1';
		
					NS_reg_clear <= '0';
					NS_green		<= '0';
					NS_yellow	<= '0';
					NS_red		<= '1';
					
					EW_reg_clear <= '0';
					EW_green		<= '1';
					EW_yellow	<= '0';
					EW_red		<= '0';
					state_debug_int <= "0100";
				when s14 | s15 => 
					NS_walk		<= '0';
					EW_walk		<= '0';
		
					NS_reg_clear <= '0';
					NS_green		<= '0';
					NS_yellow	<= '0';
					NS_red		<= '1';
					
					EW_reg_clear <= '1';
					EW_green		<= '0';
					EW_yellow	<= '1';
					EW_red		<= '0';
					state_debug_int <= "0101";
			end case; 
			
CASE current_state IS
WHEN S0 =>
state_number <= "0000";
WHEN S1 =>
state_number <= "0001";
WHEN S2 =>
state_number <= "0010";
WHEN S3 =>
state_number <= "0011";
WHEN S4 =>
state_number <= "0100";
WHEN S5 =>
state_number <= "0101";
WHEN S6 =>
state_number <= "0110";
WHEN S7 =>
state_number <= "0111";
WHEN S8 =>
state_number <= "1000";
WHEN S9 =>
state_number <= "1001";
WHEN S10 =>
state_number <= "1010";
WHEN S11 =>
state_number <= "1011";
WHEN S12 =>
state_number <= "1100";
WHEN S13 =>
state_number <= "1101";
WHEN S14 =>
state_number <= "1110";
WHEN S15 =>
state_number <= "1111";
END CASE;
	
	
		end process;
	
	 
	
	
	
	 end architecture cir;
