library ieee;
use ieee.std_logic_1164.all;

entity soc is
  generic
  (
    firmware_filename : string  := "firmware.bin";
    addr_width        : natural := 16;
    data_width        : natural := 8
  );
  port
  (
    clock   : in std_logic; -- Clock signal - Sinal de clock
    started : in std_logic -- Start execution when '1' - Iniciar a execução quando '1'
  );
end entity soc;

architecture behavioral of soc is -- Architecture declaration - Declaração da arquitetura

  signal primem_data_read  : std_logic; -- Signal to read from primary memory - Sinal para ler da memória primária
  signal primem_data_write : std_logic; -- Signal to write to primary memory - Sinal para escrever na memória primária
  signal primem_data_addr  : std_logic_vector(15 downto 0); -- Address of primary memory - Endereço da memória primária
  signal primem_data_in    : std_logic_vector(15 downto 0); -- Data to write to primary memory - Dado para escrever na memória primária
  signal primem_data_out   : std_logic_vector(31 downto 0); -- Data read from primary memory - Dado lido da memória primária

  signal secmem_data_read  : std_logic; -- Signal to read from secondary memory - Sinal para ler da memória secundária
  signal secmem_data_write : std_logic; -- Signal to write to secondary memory - Sinal para escrever na memória secundária
  signal secmem_data_addr  : std_logic_vector(15 downto 0); -- Address of secondary memory - Endereço da memória secundária
  signal secmem_data_in    : std_logic_vector(15 downto 0); -- Data to write to secondary memory - Dado para escrever na memória secundária
  signal secmem_data_out   : std_logic_vector(31 downto 0); -- Data read from secondary memory - Dado lido da memória secundária

  signal codec_interrupt : std_logic; -- Interrupt signal - Sinal de interrupção
  signal codec_read      : std_logic; -- Read signal - Sinal de leitura
  signal codec_write     : std_logic; -- Write signal - Sinal de escrita
  signal codec_valid     : std_logic; -- Valid signal - Sinal de validade
  signal codec_data_in   : std_logic_vector(7 downto 0); -- Byte written to codec - Byte gravado no codec
  signal codec_data_out  : std_logic_vector(7 downto 0); -- Byte read from codec - Byte lido do codec

begin

  primem : entity work.memory(behavioral) -- Primary memory - Memória primária
    generic
    map (
    addr_width => 16,
    data_width => 8
    )
    port map
    (
      clock      => clock,
      data_read  => primem_data_read,
      data_write => primem_data_write,
      data_addr  => primem_data_addr,
      data_in    => primem_data_in,
      data_out   => primem_data_out
    );

  secmem : entity work.memory(behavioral) -- Secondary memory - Memória secundária
    generic
    map (
    addr_width => 16,
    data_width => 8
    )
    port
    map (
    clock      => clock,
    data_read  => secmem_data_read,
    data_write => secmem_data_write,
    data_addr  => secmem_data_addr,
    data_in    => secmem_data_in,
    data_out   => secmem_data_out
    );

  codec_inst : entity work.codec -- Codec - Codec

    port
    map (
    interrupt      => codec_interrupt,
    read_signal    => codec_read,
    write_signal   => codec_write,
    valid          => codec_valid,
    codec_data_in  => codec_data_out,
    codec_data_out => codec_data_in
    );

  cpu_inst : entity work.cpu -- CPU - Port map da entidade cpu
    generic
    map (
    addr_width => 16,
    data_width => 8
    )
    port
    map (
    clock            => clock,
    halt             => '0',
    instruction_in   => primem_data_out(7 downto 0),
    instruction_addr => primem_data_addr,
    mem_data_read    => secmem_data_read,
    mem_data_write   => secmem_data_write,
    mem_data_addr    => secmem_data_addr,
    mem_data_in      => secmem_data_in,
    mem_data_out     => secmem_data_out,
    codec_interrupt  => codec_interrupt,
    codec_read       => codec_read,
    codec_write      => codec_write,
    codec_valid      => codec_valid,
    codec_data_out   => codec_data_out,
    codec_data_in    => codec_data_in
    );

end architecture behavioral;