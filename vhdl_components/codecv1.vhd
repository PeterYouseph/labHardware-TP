library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity codec is
  port
  (
    interrupt      : in std_logic; -- Interrupt signal - Sinal de interrupção
    read_signal    : in std_logic; -- Read signal - Leitura de sinal
    write_signal   : in std_logic; -- Write signal - Escrita de sinal
    valid          : out std_logic; -- Valid signal - Sinal válido
    codec_data_in  : in std_logic_vector(7 downto 0); -- Byte written to codec - Byte escrito no codec
    codec_data_out : out std_logic_vector(7 downto 0) -- Byte read from codec - Byte lido pelo codec
  );
end entity codec;

architecture behavioral of codec is
  signal data_buffer   : std_logic_vector(7 downto 0) := (others => '0'); -- Data buffer to hold the byte read from/written to codec - Buffer de dados para armazenar o byte lido / escrito no codec
  signal is_data_valid : boolean                      := false; -- Flag to indicate whether data is valid or not - Flag de indicação se os dados são válidos ou não

  -- File variables
  file input_file : file of bit;
  file output_file : file of bit;
  variable byte_buffer : bit_vector(7 downto 0);
  

begin
  process (interrupt, read_signal, write_signal, codec_data_in)
  begin
    if interrupt = '1' then
      if read_signal = '1' then
        -- Instruction is IN, read a byte from the simulated input device

        if file_open(input_file, "path_to_input_file.bin", READ_MODE) = STATUS_OK then -- Open the file
          
          while not endfile(input_file) loop -- Loop until the end of the file
            read(input_file, byte_buffer); -- Read a byte
            data_buffer <= std_logic_vector(byte_buffer); -- Assign the byte_buffer to data_buffer
            is_data_valid <= true; -- Signal that valid data is available - Sinal que dados validos
          end loop;
          file_close(input_file); -- Close the file

        else
          is_data_valid <= false; -- Signal that no valid data is available - Sinal que não existem dados válidos disponíveis
        end if;

      elsif write_signal = '1' then

        -- Instruction is OUT, write a byte to the simulated output device
        data_buffer <= codec_data_in; -- Convert the data_buffer to a bit vector
        if file_open(output_file, "path_to_output_file.bin", WRITE_MODE) = STATUS_OK then -- Open the file

          while write_signal = '1' loop -- Loop until the write signal is high
            byte_buffer := bit_vector(codec_data_in); -- Convert the data_buffer to a bit vector
            write(output_file, byte_buffer); -- Write the byte
            is_data_valid <= true; -- Signal that valid data is available - Sinal que dados validos s

          end loop;
          file_close(output_file); -- Close the file

        else
          is_data_valid <= false; -- Signal that no valid data is available - Sinal que nao existem dados disponíveis
        end if;
      end if;
    else
      is_data_valid <= false; -- No valid data available - Nenhum dado válido disponível
    end if;
  end process;

  valid <= '1' when is_data_valid else
    '0'; -- Set valid signal based on is_data_valid flag - Define o sinal válido com base na flag do is_data_valid

  -- Output the data in data_buffer when valid = '1' - Dados de saída no data_buffer quando valid = '1'
  codec_data_out <= data_buffer when is_data_valid else
    (others => 'Z');
end architecture behavioral;
