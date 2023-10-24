use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity codec is
  port
  (
    interrupt      : in std_logic; -- Interrupt signal
    read_signal    : in std_logic; -- Read signal
    write_signal   : in std_logic; -- Write signal
    valid          : out std_logic; -- Valid signal
    codec_data_in  : in std_logic_vector(7 downto 0); -- Byte written to the codec
    codec_data_out : out std_logic_vector(7 downto 0) -- Byte read from the codec
  );
end entity codec;

architecture behavioral of codec is
  signal data_buffer        : std_logic_vector(7 downto 0) := (others => '0');
  signal is_data_valid      : boolean                      := false;
  file input_file           : text open READ_MODE is "input.bin";
  shared variable file_line : line;
  shared variable file_data : integer := 0;
  shared variable file_sum  : integer := 0;
begin
  process (interrupt, read_signal, write_signal, codec_data_in)
  begin
    if interrupt = '1' then
      if read_signal = '1' then
        if not is_data_valid then
          -- Read from file
          if not endfile(input_file) then
            readline(input_file, file_line);
            read(file_line, file_data);
            file_sum := file_sum + file_data;
          end if;

          if endfile(input_file) then
            data_buffer   <= std_logic_vector(to_unsigned(file_sum, 8));
            is_data_valid <= true;
          end if;
        end if;
      elsif write_signal = '1' then
        if not is_data_valid then
          data_buffer   <= codec_data_in;
          is_data_valid <= true;
        end if;
      end if;
    end if;

    if is_data_valid then
      codec_data_out <= data_buffer;
      valid          <= '1';
    else
      valid <= '0';
    end if;
  end process;

end architecture behavioral;