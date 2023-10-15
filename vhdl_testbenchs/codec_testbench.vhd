library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity codec_tb is
end entity codec_tb;

architecture testbench of codec_tb is
  -- Component declaration for the codec entity
  component codec is
    port
    (
      interrupt      : in std_logic;
      read_signal    : in std_logic;
      write_signal   : in std_logic;
      valid          : out std_logic;
      codec_data_in  : in std_logic_vector(7 downto 0);
      codec_data_out : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Signals for the testbench
  signal interrupt : std_logic := '0';
  signal read_signal : std_logic := '0';
  signal write_signal : std_logic := '0';
  signal valid : std_logic;
  signal codec_data_in : std_logic_vector(7 downto 0) := (others => '0');
  signal codec_data_out : std_logic_vector(7 downto 0);
  
  -- File variables for input and output files
  file input_file : file of bit;
  file output_file : file of bit;
  variable byte_buffer : bit_vector(7 downto 0);
  
begin
    -- Instância do componente CODEC
    UUT : codec
        port map (
            interrupt => interrupt,
            read_signal => read_signal,
            write_signal => write_signal,
            valid => valid,
            codec_data_in => codec_data_in,
            codec_data_out => codec_data_out
         );
    
    -- Processo de clock
    process
    begin
        -- terminar o test bench
        wait;
    end process;
end architecture;
