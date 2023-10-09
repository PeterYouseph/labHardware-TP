-- O processador a ser implementado possui as caracter´ısticas de uma arquitetura MISC (Minimal Instruction Set Computer ): ele possui poucas instru¸c˜oes
-- e todas as instru¸c˜oes s˜ao simples, isto ´e, cada instru¸c˜ao executa somente uma
-- opera¸c˜ao. Al´em disso, este processador trabalha com dados (palavras) de 1
-- byte (8 bits) de largura, suporta complemento de 2 e acessa duas mem´orias:
-- uma de instru¸c˜oes (IMEM) e uma de dados(DMEM), ambas usando um endere¸co de 16 bits de largura. Em outras palavras: a capacidade m´axima de
-- cada mem´oria ´e de 216 = 65536 bytes = 64 KiB.
-- De modo a manter a arquitetura simples, este processador n˜ao possui
-- registradores de prop´osito geral. Todas as instru¸c˜oes presentes neste processador operam os dados diretamente em mem´oria: em outras palavras, esta
-- arquitetura ´e uma arquitetura de pilha1
-- .
-- Da mesma forma, para manter sua implementa¸c˜ao simples, por´em n˜ao
-- menos robusta, o conjunto de instru¸c˜oes n˜ao fornece algumas facilidades
-- ao programador tais como instru¸c˜oes de diferentes tipos e modos de endere¸camento.

-- 3.1.1 Modelo de execu¸c˜ao
-- A arquitetura desse processador possui somente dois registradores denominados IP e SP. O registrador IP (Instruction Pointer ) armazena o endere¸co da
-- instru¸c˜ao a ser executada. Logo, ele aponta para um endere¸co da mem´oria
-- de instru¸c˜oes (IMEM) do SoC. O registrador SP (Stack Pointer, ponteiro da
-- pilha) armazena o endere¸co do topo da pilha. A pilha, ´e a principal estrutura
-- de dados desta arquitetura sendo armazenada exclusivamente na mem´oria de
-- dados (DMEM) do SoC. Por tanto, o registrador SP aponta para o ´ultimo elemento da pilha. Como ambos os registradores s˜ao ponteiros para mem´oria,
-- ambos armazenam endere¸cos de 16 bits de largura.
-- O ciclo de execu¸c˜ao de uma instru¸c˜ao nessa arquitetura deve seguir os
-- seguintes passos:
-- 1. CPU acessa IMEM no endere¸co apontado por IP;
-- 2. CPU recebe instru¸c˜ao da IMEM e a decodifica;
-- 3. CPU executa instru¸c˜ao (aplica opera¸c˜ao);
-- 4. CPU altera IP
-- • Incrementa em uma unidade, caso n˜ao seja um desvio;
-- • Com endere¸co de destino, caso seja um desvio;

-- 5. Volta ao passo 1.
-- Ao ligar o processador, o mesmo deve inicializar os registradores IP e SP
-- com valor zero. Dessa forma, o processador ir´a buscar a primeira instru¸c˜ao
-- a ser executada na mem´oria de instru¸c˜oes: IMEM[IP], ou seja, IMEM[0]. Da
-- mesma forma, o registrador SP apontar´a para a mem´oria de dados na posi¸c˜ao:
-- DMEM[SP], ou seja, DMEM[0].
-- 3.1.2 Conjunto de instru¸c˜oes
-- Cada instru¸c˜ao suportada pelo processador tem tamanho fixo de 1 byte de
-- comprimento. A arquitetura possui somente um formato de instru¸c˜ao, que
-- pode ser visto na Figura 1. O campo “Opcode” cont´em o c´odigo de opera¸c˜ao
-- da instru¸c˜ao, possui 4 bytes de comprimento, ´e ´unico para cada instru¸c˜ao e ´e
-- localizado nos 4 bits mais significativos (bits 7 a 4) da instru¸c˜ao. A Tabela 1
-- lista todas as instru¸c˜oes suportadas com os opcodes, como devem funcionar
-- e seus respectivos mneumˆonicos.
-- Opcode Immediate
-- 7 6 5 4 3 2 1 0
-- Como mencionado anteriormente, a arquitetura deste processador ´e uma
-- arquitetura de pilha. Dessa forma, quando uma instru¸c˜ao necessitar de v´arios
-- operandos da pilha para funcionar, o operando denominado “Op1” ser´a o
-- operando presente no topo da pilha, isto ´e, apontado por SP. O operando
-- denominado “Op2” estaria presente abaixo do operando “Op1”, isto ´e, no
-- endere¸co dado por SP-1. Por consequˆencia, o operando denominado “Op3”
-- estaria abaixo de “Op2” na pilha (no endere¸co SP-2), e assim por diante.
-- Uma excess˜ao s˜ao as instru¸c˜oes PUSHIP, JEQ e JMP. Como elas trabalham com operandos que s˜ao endere¸cos de mem´oria (16 bits = 2 bytes), elas precisar˜ao armazenar na pilha (ou recuperar dela) 2 bytes de informa¸c˜ao. Por´em, isso dever´a ser feito durante a execu¸c˜ao da instru¸c˜ao de
-- forma impl´ıcita ao programador, n˜ao causando maiores transtornos no desenvolvimento do software para este processador.
-- Instru¸c˜oes que n˜ao utilizem o campo Immediate devem preenche-lo sempre com o valor zero. Por exemplo, uma instru¸c˜ao NAND, cujo opcode ´e 0xA,
-- ser´a codificada em bin´ario como 101000002. J´a a instru¸c˜ao PUSH 3, cujo
-- opcode ´e 0x4, ser´a codificada em bin´ario como 010000112.
-- Apesar do conjunto de instru¸c˜oes n˜ao contemplar instru¸c˜oes aritm´eticas
-- mais complexas como divis˜ao e resto, essas mesmas opera¸c˜oes podem ser
-- executadas algoritmicamente com instru¸c˜oes de soma, subtra¸c˜ao e la¸cos. O
-- mesmo vale para outras instru¸c˜oes l´ogicas, como NOT, AND e OR, que
-- podem ser feitas atrav´es da opera¸c˜ao l´ogica universal NAND.
-- Tabela 1: Listagem do conjunto de instru¸c˜oes suportadas pelo processador.
-- Operandos (Op1, Op2, Op3) sempre tem 1 byte a n˜ao ser quando indicado
-- em contr´ario.
-- Opcode Mneumˆonico Significado
-- 0x0 HLT Interrompe execu¸c˜ao indefinidamente.
-- 0x1 IN Empilha um byte recebido do codec.
-- 0x2 OUT Desempilha um byte e o envia para o codec.
-- 0x3 PUSHIP Empilha o endere¸co armazenado no registrador IP(2
-- bytes, primeiro MSB2
-- e depois LSB3
-- ).
-- 0x4 PUSH imm Empilha um byte contendo imediato (armazenado nos
-- 4 bits menos significativos da instru¸c˜ao)
-- 0x5 DROP Elimina um elemento da pilha.
-- 0x6 DUP Reempilha o elemento no topo da pilha.
-- 0x8 ADD Desempilha Op1 e Op2 e empilha (Op1 + Op2).
-- 0x9 SUB Desempilha Op1 e Op2 e empilha (Op1 − Op2).
-- 0xA NAND Desempilha Op1 e Op2 e empilha NAND(Op1, Op2).
-- 0xB SLT Desempilha Op1 e Op2 e empilha (Op1 < Op2).
-- 0xC SHL Desempilha Op1 e Op2 e empilha (Op1 ≪ Op2).
-- 0xD SHR Desempilha Op1 e Op2 e empilha (Op1 ≫ Op2).
-- 0xE JEQ Desempilha Op1(1 byte), Op2(1 byte) e Op3(2 bytes);
-- Verifica se (Op1 = Op2), caso positivo soma Op3 no
-- registrador IP.
-- 0xF JMP Desempilha Op1(2 bytes) e o atribui no registrador
-- IP.
-- A instru¸c˜ao Halt (HLT) interrompe o ciclo de execu¸c˜ao indefinidamente.
-- O processador s´o volta a execu¸c˜ao ap´os um hard-reset, isto ´e, ap´os o mesmo
-- ser desligado e ligado novamente atrav´es do sinal de entrada halt.
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