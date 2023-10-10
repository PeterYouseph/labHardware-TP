library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity codec_tb is
end entity codec_tb;

architecture testbench of codec_tb is
  component codec is
    port
    (
      interrupt      : in std_logic; -- Interrupt signal - Sinal de interrupção
      read_signal    : in std_logic; -- Read signal - Sinal de leitura
      write_signal   : in std_logic; -- Write signal - Sinal de escrita
      valid          : out std_logic; -- Valid signal - Sinal de validade
      codec_data_in  : in std_logic_vector(7 downto 0); -- Byte written to codec - Byte escrito no codec
      codec_data_out : out std_logic_vector(7 downto 0) -- Byte read from codec - Byte lido do codec
    );
  end component codec;

  -- Sinais temporários para o testbench

  signal interrupt      : std_logic := '0';
  signal read_signal    : std_logic := '0';
  signal write_signal   : std_logic := '0';
  signal valid          : std_logic;
  signal codec_data_in  : std_logic_vector(7 downto 0) := (others => '0');
  signal codec_data_out : std_logic_vector(7 downto 0);

begin
  uut : codec
  port map
  (
    interrupt      => interrupt,
    read_signal    => read_signal,
    write_signal   => write_signal,
    valid          => valid,
    codec_data_in  => codec_data_in,
    codec_data_out => codec_data_out
  );

  -- Test case 1: Write data to codec - Escrever dados no codec
  write_test : process
  begin
    wait for 10 ns;
    interrupt     <= '1';
    write_signal  <= '1';
    codec_data_in <= "01010101";
    wait for 10 ns;
    write_signal <= '0';
    wait for 10 ns;
    interrupt <= '0';
    wait for 10 ns;
    assert valid = '1' report "Data is not valid" severity error;
    assert codec_data_out = "01010101" report "Data read from codec does not match expected value - Dados lidos pelo codec não conferem com o valor esperado" severity error;
    wait;
  end process;

  -- Test case 2: Read data from codec - Ler dados do codec
  read_test : process
  begin
    wait for 10 ns;
    interrupt   <= '1';
    read_signal <= '1';
    wait for 10 ns;
    read_signal <= '0';
    wait for 10 ns;
    interrupt <= '0';
    wait for 10 ns;
    assert valid = '1' report "Data is not valid - Dados não são válidos" severity error;
    assert codec_data_out = "01010101" report "Data read from codec does not match expected value - Dados lidos a partir do codec não conferem com o valor esperado" severity error;
    wait;
  end process;

  -- Test case 3: Read data from codec when no data is available - Ler dados do codec quando não há dados disponíveis
  no_data_test : process
  begin
    wait for 10 ns;
    interrupt   <= '1';
    read_signal <= '1';
    wait for 10 ns;
    read_signal <= '0';
    wait for 10 ns;
    interrupt <= '0';
    wait for 10 ns;
    assert valid = '0' report "Data is valid when no data is available - Dados indisponíveis com vali = '0'" severity error;
    wait;
  end process;

end architecture testbench;