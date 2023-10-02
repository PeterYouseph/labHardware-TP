-- FILEPATH: processor.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  port
  (
    clk      : in std_logic;
    reset    : in std_logic;
    data_in  : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0)
  );
end entity processor;

architecture rtl of processor is
  signal reg_a   : unsigned(7 downto 0);
  signal reg_b   : unsigned(7 downto 0);
  signal alu_out : unsigned(7 downto 0);
begin
  process (clk, reset)
  begin
    if reset = '1' then
      reg_a <= (others => '0');
      reg_b <= (others => '0');
    elsif rising_edge(clk) then
      case data_in(7 downto 4) is
        when "0000" =>
          reg_a <= unsigned(data_in(3 downto 0));
        when "0001" =>
          reg_b <= unsigned(data_in(3 downto 0));
        when "0010" =>
          alu_out <= reg_a + reg_b;
        when "0011" =>
          alu_out <= reg_a - reg_b;
        when "0100" =>
          alu_out <= reg_a and reg_b;
        when "0101" =>
          alu_out <= reg_a or reg_b;
        when "0110" =>
          alu_out <= reg_a xor reg_b;
        when "0111" =>
          alu_out <= not reg_a;
        when others        =>
          alu_out <= (others => '0');
      end case;
    end if;
  end process;

  data_out <= std_logic_vector(alu_out);
end architecture rtl;