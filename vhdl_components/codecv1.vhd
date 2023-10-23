library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_textio.all;


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

  --file variables
  type file_type is file of bit;
  file input_file : file_type open read_mode is "input.txt";
  file output_file : file_type open write_mode is "output.txt";

begin

  process (interrupt, read_signal, write_signal, codec_data_in)
    variable byte_count  : integer                      := 0; -- Variable to count the number of bytes read/written - Variável para contar o número de bytes lidos / escritos
  
  begin

    if interrupt = '1' then

      if read_signal = '1' then -- Instruction is IN, read a byte from the simulated input device - Se a instrução é IN, leia um byte do dispositivo de entrada simulado
        while not endfile(input_file) loop 
          read(input_file, data_buffer(byte_count)); 
          byte_count := byte_count + 1;
        end loop;
        if endfile(input_file) then
          close(input_file);
        end if;
        -- Write the data to be read to codec_data_out - Escreva os dados a serem lidos em codec_data_out
        codec_data_out <= data_buffer;
        is_data_valid <= true; -- Signal that valid data is available - Sinal is_data_valid que dados válidos estão disponíveis

      elsif write_signal = '1' then -- Instruction is OUT, write a byte to the simulated output device - Se a instrução é OUT, escreva um byte no dispositivo de saída simulado

        data_buffer   <= codec_data_in; -- Write the data to be written to codec_data_in - Escreva os dados a serem gravados em codec_data_in
        for i in 0 to 7 loop
          write(output_file, data_buffer(i));
        end loop;
        is_data_valid <= true; -- Signal that data has been written successfully - Sinal is_data_valid que os dados foram gravados com sucesso
        if byte_count = 8 then
          close(output_file);
        end if;
      end if;

    else
      is_data_valid <= false; -- No valid data available - Nenhum dado válido disponível
    end if;
  end process;
  valid <= '1' when is_data_valid = true else '0'; -- Set valid signal - Sinal válido
  
end architecture behavioral;
