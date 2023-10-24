library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity cpu is
  generic
  (
    addr_width : natural := 16; -- Memory Address Width (in bits)
    data_width : natural := 8 -- Data Width (in bits)
  );
  port
  (
    clock : in std_logic; -- Clock signal
    halt  : in std_logic; -- Halt processor execution when '1'

    ---- Begin Memory Signals ---
    -- Instruction byte received from memory
    instruction_in : in std_logic_vector(data_width - 1 downto 0);
    -- Instruction address given to memory
    instruction_addr : out std_logic_vector(addr_width - 1 downto 0);

    mem_data_read  : out std_logic; -- When '1', read data from memory
    mem_data_write : out std_logic; -- When '1', write data to memory
    -- Data address given to memory
    mem_data_addr : out std_logic_vector(addr_width - 1 downto 0);
    -- Data sent from memory when data_read = '1' and data_write = '0'
    mem_data_in : out std_logic_vector((data_width * 2) - 1 downto 0);
    -- Data sent to memory when data_read = '0' and data_write = '1'
    mem_data_out : in std_logic_vector((data_width * 4) - 1 downto 0);
    ---- End Memory Signals ---

    ---- Begin Codec Signals ---
    codec_interrupt : out std_logic; -- Interrupt signal
    codec_read      : out std_logic; -- Read signal
    codec_write     : out std_logic; -- Write signal
    codec_valid     : in std_logic; -- Valid signal

    -- Byte written to codec
    codec_data_out : in std_logic_vector(7 downto 0);
    -- Byte read from codec
    codec_data_in : out std_logic_vector(7 downto 0)
    ---- End Codec Signals ---
  );
end entity;

architecture behavioral of cpu is
  signal ip    : std_logic_vector(addr_width - 1 downto 0); -- Instruction Pointer
  signal sp    : unsigned(addr_width - 1 downto 0); -- Stack Pointer
  signal stack : std_logic_vector((data_width * 4) - 1 downto 0); -- Stack memory

  -- Temporary registers for instruction decoding and execution
  signal opcode             : std_logic_vector(3 downto 0);
  signal imm                : std_logic_vector(data_width - 1 downto 0);
  signal op1, op2, op3      : std_logic_vector(data_width - 1 downto 0);
  signal continue_execution : boolean; -- Variável de controle

begin
  process (clock)
  begin
    if rising_edge(clock) then
      if halt = '0' then
        -- Fetch instruction from IMEM using ip
        instruction_addr <= ip;
        mem_data_read    <= '1';

        -- Decode instruction (opcode and immediate value)
        opcode <= instruction_in(7 downto 4);
        imm    <= instruction_in(3 downto 0);

        -- Implement instruction execution based on opcode
        case opcode is
          when "0000" => -- HLT
            -- Implement halt logic
            -- Para parar o processador, você pode desativar o clock, que impedirá que o processador continue executando instruções.
            if halt = '1' then
              continue_execution <= false;
            end if;

          when "0001" => -- IN
            codec_read <= '1'; -- Solicitar leitura do codec
          when "0010" => -- OUT
            codec_write <= '1'; -- Solicitar escrita no codec
          when "0011" => -- PUSHIP
            -- Implement PUSHIP logic
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= ip;
            sp                                                  <= sp - to_unsigned(2, addr_width); -- Subtrai 2 da pilha
          when "0100" => -- PUSH imm
            -- Implement PUSH immediate value logic
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= imm;
            sp                                                  <= sp - to_unsigned(2, addr_width); -- Subtrai 2 da pilha
          when "0101" => -- DROP
            -- Implement DROP logic
            sp <= sp + to_unsigned(2, addr_width); -- Adiciona 2 à pilha
          when "0110" => -- DUP
            -- Implement DUP logic
            stack(to_integer(sp) - 1 downto to_integer(sp)) <= stack(to_integer(sp) - 2 downto to_integer(sp) - 1);
            sp                                              <= sp + to_unsigned(2, addr_width); -- Adiciona 2 à pilha
          when "1110" => -- JMP
            -- Implement JMP logic
            ip <= imm;
          when "1111" => -- JEQ
            -- Implement JEQ logic
            if op1 = op2 then
              ip <= imm;
            else
              ip <= std_logic_vector(unsigned(ip) + 1);
            end if;
          when others =>
            -- Implement logic for other opcodes
        end case;

        -- Atualize ip para a próxima instrução
        if opcode /= "1110" and opcode /= "1111" then -- Não é JMP ou JEQ
          ip <= std_logic_vector(unsigned(ip) + 1); -- Adiciona 1 a ip
        end if;
      end if;
    end if;
  end process;
end architecture behavioral;