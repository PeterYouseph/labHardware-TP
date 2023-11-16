library ieee;
use ieee.std_logic_1164.all;

entity soc is
    generic (
        firmware_filename: string := "firmware.bin";
        addr_width: natural := 16;
        data_width: natural := 8 
    );
    port (
        clock: in std_logic;  -- Clock signal
        started: in std_logic -- Start execution when '1'
    );
end entity soc;

architecture behavioral of soc is
    
    signal primem_data_read: std_logic;
    signal primem_data_write: std_logic;
    signal primem_data_addr: std_logic_vector(15 downto 0);
    signal primem_data_in: std_logic_vector(15 downto 0);
    signal primem_data_out: std_logic_vector(31 downto 0);

    signal secmem_data_read: std_logic;
    signal secmem_data_write: std_logic;
    signal secmem_data_addr: std_logic_vector(15 downto 0);
    signal secmem_data_in: std_logic_vector(15 downto 0);
    signal secmem_data_out: std_logic_vector(31 downto 0);

    signal codec_interrupt : std_logic;
    signal codec_read : std_logic;
    signal codec_write : std_logic;
    signal codec_valid : std_logic;
    signal codec_data_in : std_logic_vector(7 downto 0);
    signal codec_data_out : std_logic_vector(7 downto 0);

begin

    primem : entity work.memory(behavioral)
    generic map (
        addr_width => 16,
        data_width => 8
    )
    port map (
        clock => clock,
        data_read => imem_data_read,
        data_write => imem_data_write,
        data_addr => imem_data_addr,
        data_in => imem_data_in,
        data_out => imem_data_out
    );

    secmem : entity work.memory(behavioral)
    generic map (
        addr_width => 16,
        data_width => 8
    )
    port map (
        clock => clock,
        data_read => dmem_data_read,
        data_write => dmem_data_write,
        data_addr => dmem_data_addr,
        data_in => dmem_data_in,
        data_out => dmem_data_out
    );

    codec_inst : entity work.codec
    generic map (
        addr_width => 16,
        data_width => 8
    )
    port map (
        interrupt => codec_interrupt,
        read_signal => codec_read,
        write_signal => codec_write,
        valid => codec_valid,
        codec_data_in => codec_data_out,
        codec_data_out => codec_data_in
    );

    cpu_inst : entity work.cpu
    generic map (
        addr_width => 16,
        data_width => 8
    )
    port map (
        clock => clock,
        halt => not started,
        instruction_in => imem_data_out(7 downto 0), 
        instruction_addr => imem_data_addr,
        mem_data_read => dmem_data_read,
        mem_data_write => dmem_data_write,
        mem_data_addr => dmem_data_addr,
        mem_data_in => dmem_data_in,
        mem_data_out => dmem_data_out,
        codec_interrupt => codec_interrupt,
        codec_read => codec_read,
        codec_write => codec_write,
        codec_valid => codec_valid,
        codec_data_out => codec_data_out,
        codec_data_in => codec_data_in
    );

end architecture behavioral;
