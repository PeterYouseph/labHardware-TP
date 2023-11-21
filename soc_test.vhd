library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.textio.all;

entity soc_test is
end entity soc_test;

architecture testbench of soc_test is -- Define the architecture of the testbench and its components - Define a arquitetura do teste e seus componentes

  signal clock_tb   : std_logic := '0';
  signal started_tb : std_logic := '0';

  signal primem_data_read_tb  : std_logic;
  signal primem_data_write_tb : std_logic;
  signal primem_data_addr_tb  : std_logic_vector(15 downto 0);
  signal primem_data_in_tb    : std_logic_vector(15 downto 0);
  signal primem_data_out_tb   : std_logic_vector(31 downto 0);

  signal secmem_data_read_tb  : std_logic;
  signal secmem_data_write_tb : std_logic;
  signal secmem_data_addr_tb  : std_logic_vector(15 downto 0);
  signal secmem_data_in_tb    : std_logic_vector(15 downto 0);
  signal secmem_data_out_tb   : std_logic_vector(31 downto 0);

  signal codec_interrupt_tb : std_logic;
  signal codec_read_tb      : std_logic;
  signal codec_write_tb     : std_logic;
  signal codec_valid_tb     : std_logic;
  signal codec_data_in_tb   : std_logic_vector(7 downto 0);
  signal codec_data_out_tb  : std_logic_vector(7 downto 0);

begin

  -- Clock process - Processo do clock da simulação
  process
  begin
    wait for 5 ns; -- initial wait
    while now < 100 ns loop
      clock_tb <= not clock_tb;
      wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process - Processo de entrada
  process
  begin
    wait for 10 ns; -- initial wait - Delay for 10 ns to start - Delay para iniciar o processo

    -- Initialize started signal - Inicializa o sinal started
    started_tb <= '1';

    -- Write a simple firmware to primary memory - Escreve um firmware simples na memória primária
    primem_data_addr_tb  <= "0000000000000000";
    primem_data_in_tb    <= "1100000011000000"; -- Example instruction: PUSH 192 (0xC0) - Instrução PUSH
    primem_data_write_tb <= '1';
    wait for 10 ns;

    primem_data_addr_tb  <= "0000000000000001";
    primem_data_in_tb    <= "1110000000000001"; -- Example instruction: JMP 1 - Instrução JMP
    primem_data_write_tb <= '1';
    wait for 10 ns;

    primem_data_write_tb <= '0'; -- Disable write - Desabilita a escrita

    wait for 100 ns;

    -- Stop the simulation - Para a simulação
    wait;

  end process;

  -- Instantiate the soc entity - Instancia a entidade soc
  uut : entity work.soc
    generic
    map (
    firmware_filename => "firmware.bin",
    addr_width        => 16,
    data_width        => 8
    )
    port map
    (
      clock   => clock_tb,
      started => started_tb
    );

  -- Observation process - Processo de observação de sinais de saída
  process
    variable primem_data_out_str : string(1 to primem_data_out_tb'length);
    variable secmem_data_out_str : string(1 to secmem_data_out_tb'length);
    variable codec_data_out_str  : string(1 to codec_data_out_tb'length);
  begin
    wait for 20 ns; -- initial wait - Atraso de 20 ns para aguarda alguns ciclos 

    -- Convert the signals to strings - Converter vetores de bits para strings
    primem_data_out_str := integer'image(to_integer(unsigned(primem_data_out_tb)));
    secmem_data_out_str := integer'image(to_integer(unsigned(secmem_data_out_tb)));
    codec_data_out_str  := integer'image(to_integer(unsigned(codec_data_out_tb)));

    -- Print some data - Imprimir algumas informações dos sinais de saida
    report "=== Estado Inicial ===";
    report "Primary Memory Data Out: " & primem_data_out_str;
    report "Secondary Memory Data Out: " & secmem_data_out_str;
    report "Codec Data Out: " & codec_data_out_str;

    wait;
  end process;

end architecture;