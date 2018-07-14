library ieee;
use ieee.std_logic_1164.all;

entity Bus_Component is
	port(
		pc : in std_logic_vector(9 downto 0);
		ar : in std_logic_vector(9 downto 0);
		inp : in std_logic_vector(7 downto 0);
		mbr : in std_logic_vector(15 downto 0);
		ac : in std_logic_vector(7 downto 0);
		sel : in std_logic_vector(2 downto 0);
		output : out std_logic_vector(15 downto 0)
	);
end Bus_Component;

architecture behavorial of Bus_Component is begin
	process(sel, pc, ar, inp, mbr, ac) begin
		case sel is
			when "000" => output <= "000000" & pc;
			when "001" => output <= "000000" & ar;
			when "010" => output <= "00000000" & inp;
			when "011" => output <= mbr;
			when "100" => output <= "00000000" & ac;
			when others =>
		end case;
	end process;
end behavorial;
