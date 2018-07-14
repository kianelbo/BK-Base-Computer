library ieee;
use ieee.std_logic_1164.all;

entity Generic_Mux is
  generic(n : natural);
	port(
		i0 : in std_logic_vector(n-1 downto 0);
		i1 : in std_logic_vector(n-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(n-1 downto 0)
	);
end Generic_Mux;

architecture behavorial of Generic_Mux is begin
	process(sel, i0, i1) begin
		case sel is
			when '0' => output <= i0;
			when '1' => output <= i1;
			when others =>
		end case;
	end process;
end behavorial;