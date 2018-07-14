library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Generic_Decoder is
	Generic (
		n: integer
	);
	Port (
		input : in STD_LOGIC_VECTOR (n-1 downto 0);
		output : out STD_LOGIC_VECTOR ((2**n)-1 downto 0)
	);
end Generic_Decoder;

architecture Behavioral of Generic_Decoder is begin
	 process(input) begin
	 		output <= (others => '0');
			output(conv_integer(input)) <= '1';
	 end process;
end Behavioral;