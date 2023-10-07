library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity codec_tb is
end entity codec_tb;

architecture sim of codec_tb is
    -- Declaração de sinais
    signal input_data      : std_logic_vector(7 downto 0) := "00000000";
    signal control_signal  : std_logic := '0';
    signal output_data     : std_logic_vector(7 downto 0);
    
    -- Declaração do componente CODEC
    component codec
        port(
            input_data     : in  std_logic_vector(7 downto 0);
            control_signal : in  std_logic;
            output_data    : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    -- Instância do componente CODEC
    UUT : codec
        port map(
            input_data     => input_data,
            control_signal => control_signal,
            output_data    => output_data
        );

    -- Processo de clock
    process
    begin
        -- Inicializações
        input_data     <= "00000000"; -- Valor inicial para input_data
        control_signal <= '0';       -- Valor inicial para control_signal

        -- Teste 1
        wait for 10 ns;
        input_data     <= "11111111"; -- Configura o valor de input_data
        control_signal <= '1';       -- Configura o valor de control_signal
        wait for 10 ns;
        -- Verifique os resultados, se necessário

        -- Teste 2
        wait for 10 ns;
        input_data     <= "01010101"; -- Configura o valor de input_data
        control_signal <= '0';       -- Configura o valor de control_signal
        wait for 10 ns;
        -- Verifique os resultados, se necessário

        -- Continue adicionando testes conforme necessário

        -- Encerra a simulação
        wait;
    end process;
end architecture sim;
