library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
 end holding_register;
 
  architecture circuit of holding_register is
	
	Signal sreg				: std_logic;
	
	signal temp_hold	: std_logic;

BEGIN

temp_hold <= (sreg OR din) AND (reset NOR register_clr);


synced_system : process(clk)
	BEGIN
		
		if (rising_edge(clk)) then
			
			sreg <= temp_hold;
			dout <= temp_hold;
		end if;
	end process;
end;