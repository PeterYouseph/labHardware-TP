library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_codec is
end tb_codec;

architecture testbench of tb_codec is

  signal interrupt      : std_logic := '0';
  signal read_signal    : std_logic := '0';
  signal write_signal   : std_logic := '0';
  signal valid          : std_logic;
  signal codec_data_in  : std_logic_vector(7 downto 0) := (others => '0');
  signal codec_data_out : std_logic_vector(7 downto 0);
  
  -- Instantiate the codec component
  component codec
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

begin

  -- Connect the signals
  UUT: codec port map (
    interrupt      => interrupt,
    read_signal    => read_signal,
    write_signal   => write_signal,
    valid          => valid,
    codec_data_in  => codec_data_in,
    codec_data_out => codec_data_out
  );

  -- Write operation test
  process
  begin
    -- Activate interrupt signal
    interrupt <= '1'; 

    -- Activate write signal
    write_signal   <= '1';
    codec_data_in  <= "11001100"; -- Example data
    
    wait for 10 ns; -- Simulate some time
    
    -- Reset write signal and data
    write_signal   <= '0';
    codec_data_in  <= (others => '0');
    
    -- Check if valid is asserted
    assert valid = '1'
      report "Write operation failed: valid signal not asserted"
      severity error;
      
    wait;
  end process;

  -- Read operation test
  process
  begin
    -- Activate interrupt signal
    interrupt <= '1';
    
    -- Activate read signal
    read_signal    <= '1';
    
    wait for 10 ns; -- Simulate some time
    
    -- Check if valid is asserted
    assert valid = '1'
      report "Read operation failed: valid signal not asserted"
      severity error;
      
    wait;
  end process;

end testbench;
