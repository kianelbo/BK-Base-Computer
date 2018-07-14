library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		input_ready : in std_logic;
		operation : in std_logic_vector(3 downto 0);
		data_in_ac : in std_logic_vector(7 downto 0);
		data_in_bus : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
end ALU;

architecture behavorial of ALU is begin
	
	process(input_ready)
		--	constants:
	constant C_NOP : std_logic_vector(3 downto 0) := "0000";
	constant C_ADD : std_logic_vector(3 downto 0) := "0001";
	constant C_SUB : std_logic_vector(3 downto 0) := "0010";
	constant C_AND : std_logic_vector(3 downto 0) := "0011";
	constant C_OR  : std_logic_vector(3 downto 0) := "0100";
	constant C_XOR : std_logic_vector(3 downto 0) := "0101";
	
	begin
	
		if(input_ready = '1') then
			case operation is
				when C_ADD => data_out <= std_logic_vector(unsigned(data_in_ac) + unsigned(data_in_bus));
				when C_SUB => data_out <= std_logic_vector(unsigned(data_in_ac) - unsigned(data_in_bus));
				when C_AND => 
					for i in 0 to 7 loop
						data_out(i) <= data_in_ac(i) and data_in_bus(i);
					end loop;
				when C_OR => 
					for i in 0 to 7 loop
						data_out(i) <= data_in_ac(i) or data_in_bus(i);
					end loop;
				when C_XOR => 
					for i in 0 to 7 loop
						data_out(i) <= data_in_ac(i) xor data_in_bus(i);
					end loop;
				when others => null;
			end case;
		end if;
	end process;
end behavorial;