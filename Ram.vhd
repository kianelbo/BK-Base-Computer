library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram is
	port(
		init : in std_logic;
		rd : in std_logic;
		wr : in std_logic;
		address : in std_logic_vector(9 downto 0);
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end Ram;

architecture behavorial of Ram is
	type mem is array (0 to 1023) of std_logic_vector(15 downto 0);
begin
	process(rd, wr, init)
		variable memory : mem := (others => (others => '0'));
	begin
		if(init = '1') then
			-- AC = 4
			memory(0) := "1001100000000100";
			 -- Increment AC
			memory(1) := "1100110000100000";
			 -- A = not A 
			memory(2) := "1100110000000100";
			 -- Clear AC
			memory(3) := "1100110000000001";
			 -- Increment AC
			memory(4) := "1100110000100000";
			 -- Add 7 to AC
			memory(5) := "1000010000000111";
			 -- Save AC in memory "1000000000"
			memory(6) := "0001111000000000";
			 -- A = not A
			memory(7) := "1100110000000100";
			 -- Shift Left AC
			memory(8) := "1100110000010000";
			 -- Load AC from memory "10000000000"
			memory(9) := "0001101000000000";
			-- Add 20 to AC
			memory(10) := "1000010000010100";
			 -- Branch to 51
			memory(11) := "0010000000110011";
			 -- Save AC in memory "10000000001"
			memory(12) := "0001111000000001";
			 -- Increment AC
			memory(13) := "1100110000100000";
			 -- Shift Right AC
			memory(14) := "1100110000001000";
			 -- Load AC from memory "10000000001"
			memory(15) := "0001101000000001";
			 -- Halt
			memory(16) := "1100110001000000";
			 -- Shift Right AC
			memory(51) := "1100110000001000";
			 -- Branch to 12
			memory(52) := "0010000000001100";
			
			-- Handle the output
			data_out <= "0000000000000000";
		end if;
		if(rd = '1') then
			data_out <= memory(to_integer(unsigned(address)));
		end if;
		if(wr = '1') then
			memory(to_integer(unsigned(address))) := data_in;
		end if;
	end process;
end behavorial;