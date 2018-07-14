library ieee;
use ieee.std_logic_1164.all;

entity DFF is
	port(
		clk : in std_logic;
		en : in std_logic;
		d : in std_logic;
		q : out std_logic
	);
end DFF;

architecture behavorial of DFF is begin
	process(clk) begin
		if(rising_edge(clk)) then
			if(en = '1') then q <= d; end if;
		end if;
	end process;
end behavorial;