library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_Generic is
  generic (
    n : integer
  );
  port(
    clk : in std_logic;
    load : in std_logic;
    inc : in std_logic;
	dec : in std_logic;
    clr : in std_logic;
    sr : in std_logic;
    sl : in std_logic;
    data_in : in std_logic_vector(n - 1 downto 0);
    data_out : out std_logic_vector(n - 1 downto 0)
  );
end Register_Generic;

architecture behavorial of Register_Generic is
  signal data : std_logic_vector(n - 1 downto 0) := (others => '0');
begin
  process(clk) begin
    if(rising_edge(clk)) then
      if(inc = '1') then
        data <= std_logic_vector(unsigned(data) + 1);
      elsif(dec = '1') then
		data <= std_logic_vector(unsigned(data) - 1);
      elsif(load = '1') then
        data <= data_in;
      elsif(clr = '1') then
        data <= (others => '0');
      elsif(sr = '1') then
        data <= std_logic_vector(shift_right(unsigned(data), 1));
      elsif(sl = '1') then
        data <= std_logic_vector(shift_left(unsigned(data), 1));
      end if;
    end if;
  end process;

  data_out <= data;
end behavorial;