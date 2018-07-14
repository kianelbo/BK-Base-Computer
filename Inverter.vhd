library ieee;
use ieee.std_logic_1164.all;

entity Inverter is
	port(
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
end Inverter;

architecture behavorial of Inverter is begin
	process(data_in) begin
			for i in 0 to 7 loop
				data_out(i) <= not data_in(i);
			end loop;
	end process;
end behavorial;