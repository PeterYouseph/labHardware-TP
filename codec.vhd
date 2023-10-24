use STD.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

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
  signal data_buffer   : std_logic_vector(7 downto 0) := (others => '0'); -- Data buffer to store the byte read/written to the codec
  signal is_data_valid : boolean                      := false; -- Flag indicating whether the data is valid or not

  -- File variables
  file input_file  : text open read_mode is "input.txt";
  file output_file : text open write_mode is "output.txt";

  shared variable bin_string   : line; -- Variable to store the binary string to be written to the output file
  shared variable read_status  : file_open_status;
  shared variable write_status : file_open_status;

begin

  process (interrupt, read_signal, write_signal, codec_data_in)
  begin
    if interrupt = '1' then
      if read_signal = '1' then -- If the instruction is IN, read a byte from the simulated input device
        read_status := file_open(input_file, read_mode);
        readline(input_file, bin_string); -- Read the binary string from the input file

        for i in codec_data_out'range loop
          data_buffer(i) <= std_logic'val(to_integer(unsigned(bin_string.all(i + 1))))(0); -- Convert the binary string to a byte
        end loop;

        if read_status /= file_open_status'openok then
          report "Error: Failed to open input file";
          assert false;
        end if;

        if endfile(input_file) then -- If the input file reaches the end, close it and open it again
          file_close(input_file);
          read_status := file_open(input_file, read_mode);
        end if;

        -- Write the data to be read into codec_data_out
        codec_data_out <= data_buffer;
        is_data_valid  <= true; -- Signal that valid data is available

      elsif write_signal = '1' then -- If the instruction is OUT, write a byte to the simulated output device
        write_status := file_open(output_file, write_mode);

        for i in codec_data_in'range loop
          write(output_file, std_logic'image(codec_data_in(i))(5)); -- Convert the byte to a binary string
        end loop;

        writeline(output_file); -- Write a newline character
        data_buffer   <= codec_data_in;
        is_data_valid <= true; -- Signal that valid data is available

        if write_status /= file_open_status'openok then
          report "Error: Failed to open output file";
          assert false;
        end if;

        if endfile(output_file) then -- If the output file reaches the end, close it and open it again
          file_close(output_file);
          write_status := file_open(output_file, write_mode);
        end if;
      end if;
    end if;
  end process;

  process (is_data_valid) -- Process which verifies if the signal valid indicates whether valid data is available or not
  begin
    if is_data_valid then
      valid <= '1';
    else
      valid <= '0';
    end if;
  end process;

end architecture behavioral;