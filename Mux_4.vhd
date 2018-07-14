library ieee;
use ieee.std_logic_1164.all;

entity Mux_4 is
	port(
		i0 : in std_logic_vector(7 downto 0);
		i1 : in std_logic_vector(7 downto 0);
		i2 : in std_logic_vector(7 downto 0);
		i3 : in std_logic_vector(7 downto 0);
		sel : in std_logic_vector(1 downto 0);
		output : out std_logic_vector(7 downto 0)
	);
end Mux_4;

architecture behavorial of Mux_4 is begin
	process(sel, i0, i1, i2, i3) begin
		case sel is
			when "00" => output <= i0;
			when "01" => output <= i1;
			when "10" => output <= i2;
			when "11" => output <= i3;
			when others =>
		end case;
	end process;
end behavorial;
