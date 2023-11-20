library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.textio.all;

entity soc_test is
end entity soc_test;

architecture testbench of soc_test is

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

  -- Clock process
  process
  begin
    wait for 5 ns; -- initial wait
    while now < 100 ns loop
      clock_tb <= not clock_tb;
      wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    wait for 10 ns; -- initial wait

    -- Initialize started signal
    started_tb <= '1';

    -- Write a simple firmware to primary memory
    primem_data_addr_tb  <= "0000000000000000";
    primem_data_in_tb    <= "1100000011000000"; -- Example instruction: PUSH 192
    primem_data_write_tb <= '1';
    wait for 10 ns;

    primem_data_addr_tb  <= "0000000000000001";
    primem_data_in_tb    <= "1110000000000001"; -- Example instruction: JMP 1
    primem_data_write_tb <= '1';
    wait for 10 ns;

    primem_data_write_tb <= '0'; -- Disable write

    wait for 100 ns;

    -- Stop the simulation
    wait;

  end process;

  -- Instantiate the soc entity
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

  -- Processo de observação de sinais
  process
    variable primem_data_out_str : string(1 to primem_data_out_tb'length);
    variable secmem_data_out_str : string(1 to secmem_data_out_tb'length);
    variable codec_data_out_str  : string(1 to codec_data_out_tb'length);
  begin
    wait for 20 ns; -- aguarda alguns ciclos

    -- Converter vetores de bits para strings
    primem_data_out_str := integer'image(to_integer(unsigned(primem_data_out_tb)));
    secmem_data_out_str := integer'image(to_integer(unsigned(secmem_data_out_tb)));
    codec_data_out_str  := integer'image(to_integer(unsigned(codec_data_out_tb)));

    -- Imprimir algumas informações
    report "=== Estado Inicial ===";
    report "Primary Memory Data Out: " & primem_data_out_str;
    report "Secondary Memory Data Out: " & secmem_data_out_str;
    report "Codec Data Out: " & codec_data_out_str;

    -- Observações adicionais podem ser adicionadas conforme necessário

    wait;
  end process;

end architecture;