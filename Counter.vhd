library ieee;
use ieee.std_logic_1164.all;

entity Counter is
	port(
		clk : in std_logic;
		clr : in std_logic;
		data_out : out std_logic_vector(1 downto 0)
	);
end Counter;

architecture behavorial of Counter is
	signal data : std_logic_vector(1 downto 0) := "00";
begin
	process(clk, clr) begin
		if(clr = '1') then
			data <= "00";
		end if;
		if(rising_edge(clk)) then
			if(clr = '0') then
				case data is
					when "00" => data <= "01";
					when "01" => data <= "10";
					when "10" => data <= "11";
					when "11" => data <= "00";
					when others => data <= "00";
				end case;
			end if;
		end if;
	end process;

	data_out <= data;
end behavorial;