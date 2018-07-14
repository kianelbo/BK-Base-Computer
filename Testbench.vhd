library ieee;
use ieee.std_logic_1164.all;

entity Testbench is
end Testbench;

architecture behavorial of Testbench is
	component Computer is
		port(
			clk : in std_logic
		);
	end component;

	signal clk : std_logic := '0';
begin
	Computer_component : Computer port map(clk => clk);

	clk <= not clk after 100 ns;
end behavorial;