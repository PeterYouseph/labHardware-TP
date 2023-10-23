library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_textio.all;


entity codec is
  port
  (
    interrupt      : in std_logic; --  Sinal de interrupção
    read_signal    : in std_logic; --  Leitura de sinal
    write_signal   : in std_logic; --  Escrita de sinal
    valid          : out std_logic; --  Sinal válido
    codec_data_in  : in std_logic_vector(7 downto 0); --  Byte escrito no codec
    codec_data_out : out std_logic_vector(7 downto 0) --  Byte lido pelo codec

  );
end entity codec;

architecture behavioral of codec is
  signal data_buffer   : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de dados para armazenar o byte lido / escrito no codec
  signal is_data_valid : boolean                      := false; --  Flag de indicação se os dados são válidos ou não

  --file variables
  type file_type is file of bit;
  file input_file : file_type open read_mode is "input.txt";
  file output_file : file_type open write_mode is "output.txt";

begin

  process (interrupt, read_signal, write_signal, codec_data_in)
    variable bin_string  : string(7 downto 0)           := (others => '0'); --  Variável para armazenar a string binária a ser escrita no arquivo de saída
  
  begin

    if interrupt = '1' then

      if read_signal = '1' then -- Se a instrução é IN, leia um byte do dispositivo de entrada simulado

        read(input_file, bin_string); --  Leia a string binária do arquivo de entrada

        for i in codec_data_out'range loop 
          data_buffer(i) := std_logic'val(bin_string(i)); --  Converta a string binária em um byte
        end loop;

        if endfile(input_file) then --  Se o arquivo de entrada terminar, feche-o e abra-o novamente
          close(input_file);
        end if;

        --  Escreva os dados a serem lidos em codec_data_out
        codec_data_out <= data_buffer;
        is_data_valid <= true; --  Sinal is_data_valid que dados válidos estão disponíveis

      elsif write_signal = '1' then --  Se a instrução é OUT, escreva um byte no dispositivo de saída simulado
        
        for i in codec_data_in'range loop 
          bin_string(i) := std_logic'image(codec_data_in(i))(0); --  Converta o byte em uma string binária
        end loop;
        
        writeline(output_file, bin_string); --  Escreva a string binária no arquivo de saída
        data_buffer <= codec_data_in;
        is_data_valid <= true; --  Sinal is_data_valid que dados válidos estão disponíveis

        if endfile(output_file) then --  Se o arquivo de saída terminar, feche-o e abra-o novamente
          close(output_file);
        end if;

      else
        is_data_valid <= false; --  Nenhum dado válido disponível
      end if;
    
    else
      is_data_valid <= false; --  Nenhum dado válido disponível
    
    end if;
  end process;
  
  valid <= '1' when is_data_valid = true else '0'; --  Sinal válido
  
end architecture behavioral;
