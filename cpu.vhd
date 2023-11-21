library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
  generic
  (
    addr_width : natural := 16; -- Memory Address Width (in bits) - Largura do endereço da memória
    data_width : natural := 8 -- Data Width (in bits) - Largura dos dados
  );
  port
  (
    clock : in std_logic; -- Clock signal - Sinal de clock
    halt  : in std_logic; -- Halt processor execution when '1' - Parar a execução do processador quando '1'

    ---- Begin Memory Signals ---
    -- Instruction byte received from memory - Byte de instrução recebido da memória
    instruction_in : in std_logic_vector(data_width - 1 downto 0);
    -- Instruction address given to memory - Endereço da instrução dado para a memória
    instruction_addr : out std_logic_vector(addr_width - 1 downto 0);

    mem_data_read  : out std_logic; -- When '1', read data from memory - Quando '1', leia dados da memória
    mem_data_write : out std_logic; -- When '1', write data to memory - Quando '1', escreva dados na memória
    -- Data address given to memory - Endereco de dados dado para a memória
    mem_data_addr : out std_logic_vector(addr_width - 1 downto 0);
    -- Data sent from memory when data_read = '1' and data_write = '0' - Dados enviados da memória quando data_read = '1' e data_write = '0'
    mem_data_in : out std_logic_vector((data_width * 2) - 1 downto 0);
    -- Data sent to memory when data_read = '0' and data_write = '1' - Dados enviados para a memória quando data_read = '0' e data_write = '1'
    mem_data_out : in std_logic_vector((data_width * 4) - 1 downto 0);
    ---- End Memory Signals ---

    ---- Begin Codec Signals ---
    codec_interrupt : out std_logic; -- Interrupt signal - Sinal de interrupção
    codec_read      : out std_logic; -- Read signal - Sinal de leitura
    codec_write     : out std_logic; -- Write signal - Sinal de escrita
    codec_valid     : in std_logic; -- Valid signal - Sinal de validade

    -- Byte written to codec - Byte gravado no codec
    codec_data_out : in std_logic_vector(7 downto 0);
    -- Byte read from codec - Byte lido do codec
    codec_data_in : out std_logic_vector(7 downto 0)
    ---- End Codec Signals ---
  );
end entity;

architecture behavioral of cpu is

  signal ip            : std_logic_vector(addr_width - 1 downto 0); -- Instruction Pointer - Ponto de Instrução
  signal sp            : unsigned(addr_width - 1 downto 0); -- Stack Pointer - Ponto de Pilha
  signal stack         : std_logic_vector((data_width * 4) - 1 downto 0); -- Stack memory - Memória da Pilha
  signal opcode        : std_logic_vector(3 downto 0); -- Opcode signal - Sinal de Opcode
  signal imm           : std_logic_vector(data_width - 1 downto 0); -- Immediate signal - Sinal de immediate
  signal op1, op2, op3 : std_logic_vector(data_width - 1 downto 0); -- Operands - Operadores de sinal
  signal stack_top     : std_logic_vector(data_width - 1 downto 0); -- Topo da pilha - Topo da pilha
  signal halted        : std_logic; -- Variável de controle de parada - Variável de controle de parada

begin
  process (clock)
  begin
    halted <= halt;
    if rising_edge(clock) then
      if halted = '0' then
        instruction_addr <= ip;
        mem_data_read    <= '1';
        opcode           <= instruction_in(7 downto 4);
        imm              <= instruction_in(3 downto 0);

        case opcode is
          when "0000" => -- HLT - Halt
            halted <= '1';
          when "0001" => -- IN - Read
            codec_read <= '1';
          when "0010" => -- OUT - Write
            codec_write <= '1';
          when "0011" => -- PUSHIP - Push IP
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= ip;
            sp                                                  <= sp - to_unsigned(2, addr_width);
          when "0100" => -- PUSH imm - Push immediate
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= imm;
            sp                                                  <= sp - to_unsigned(2, addr_width);
          when "0101" => -- DROP - Drop 
            sp <= sp + to_unsigned(2, addr_width);
          when "0110" => -- DUP - Duplicate
            stack(to_integer(sp) - 1 downto to_integer(sp)) <= stack(to_integer(sp) - 2 downto to_integer(sp) - 1);
            sp                                              <= sp + to_unsigned(2, addr_width);
          when "1110" => -- JMP - Jump 
            ip <= imm;
            ip <= std_logic_vector(unsigned(ip) + 1);

          when "1111" => -- JEQ - Jump if equal
            if op1 = op2 then
              ip <= imm;
            else
              ip <= std_logic_vector(unsigned(ip) + 1);
            end if;
            ip <= std_logic_vector(unsigned(ip) + 1);

          when "1000" => -- ADD - Add 
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(op1) + unsigned(op2));
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1001" => -- SUB - Subtract
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(op2) - unsigned(op1));
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1010" => -- NAND - NAND
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= not (op1 and op2);
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1011" => -- SLT - SLT
            op1 <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2 <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3 <= (others => '0'); -- Clear op3 - Clear op3
            if signed(op2) < signed(op1) then
              stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= (others => '1');
            else
              stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= (others => '0');
            end if;
            sp <= sp - to_unsigned(2, addr_width);

          when "1100" => -- SHL
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= (others => '0'); -- Clear op2 - limpa op2
            op3                                                          <= (others => '0'); -- Clear op3 - limpa op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(stack(to_integer(sp) - 1 downto to_integer(sp) - data_width)) sll 1);
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1101" => -- SHR 
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= (others => '0'); -- Clear op2 - limpa op2
            op3                                                          <= (others => '0'); -- Clear op3 - limpa op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(stack(to_integer(sp) - 1 downto to_integer(sp) - data_width)) srl 1);
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when others =>
        end case;
        if opcode /= "1110" and opcode /= "1111" then
          ip <= std_logic_vector(unsigned(ip) + 1);
        end if;
      end if;
    end if;
  end process;

end architecture behavioral;