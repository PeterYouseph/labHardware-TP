-- FILEPATH: codec_component.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity codec is
  port
  (
    clk      : in std_logic;
    reset    : in std_logic;
    data_in  : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);
    encode   : in std_logic;
    decode   : in std_logic
  );
end entity codec;

architecture rtl of codec is
  signal reg_data : std_logic_vector(7 downto 0);
begin
  process (clk, reset)
  begin
    if reset = '1' then
      reg_data <= (others => '0');
    elsif rising_edge(clk) then
      if encode = '1' then
        -- encode data
        case reg_data is
          when "00000000" =>
            data_out <= "00110000"; -- '0'
          when "00000001" =>
            data_out <= "00110001"; -- '1'
            -- add more cases for other ASCII characters
          when others =>
            data_out <= "00000000"; -- invalid character
        end case;
      elsif decode = '1' then
        -- decode data
        case data_in is
          when "00110000" =>
            reg_data <= "00000000"; -- '0'
          when "00110001" =>
            reg_data <= "00000001"; -- '1'
            -- add more cases for other ASCII characters
          when others =>
            reg_data <= "00000000"; -- invalid character
        end case;
        data_out <= reg_data;
      end if;
    end if;
  end process;
end architecture rtl;