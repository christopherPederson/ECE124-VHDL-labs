library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset			: in std_logic;
			din			: in std_logic;
			dout			: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN
	process(clk)
	begin
		if reset = '1' then 
			sreg <= "00";
		elsif (rising_edge(clk)) then
				sreg(1) <= sreg(0);
				sreg(0) <= din;
		end if;
	end process;
		
	dout <= sreg(1);

end;