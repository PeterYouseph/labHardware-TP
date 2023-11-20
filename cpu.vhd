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

  signal ip            : std_logic_vector(addr_width - 1 downto 0); -- Instruction Pointer
  signal sp            : unsigned(addr_width - 1 downto 0); -- Stack Pointer
  signal stack         : std_logic_vector((data_width * 4) - 1 downto 0); -- Stack memory
  signal opcode        : std_logic_vector(3 downto 0);
  signal imm           : std_logic_vector(data_width - 1 downto 0);
  signal op1, op2, op3 : std_logic_vector(data_width - 1 downto 0);
  signal stack_top     : std_logic_vector(data_width - 1 downto 0); -- Topo da pilha
  signal halted        : std_logic; -- Variável de controle

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
          when "0000" => -- HLT
            halted <= '1';
          when "0001" => -- IN
            codec_read <= '1';
          when "0010" => -- OUT
            codec_write <= '1';
          when "0011" => -- PUSHIP
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= ip;
            sp                                                  <= sp - to_unsigned(2, addr_width);
          when "0100" => -- PUSH imm
            stack(to_integer(sp) - 1 downto to_integer(sp) - 2) <= imm;
            sp                                                  <= sp - to_unsigned(2, addr_width);
          when "0101" => -- DROP
            sp <= sp + to_unsigned(2, addr_width);
          when "0110" => -- DUP
            stack(to_integer(sp) - 1 downto to_integer(sp)) <= stack(to_integer(sp) - 2 downto to_integer(sp) - 1);
            sp                                              <= sp + to_unsigned(2, addr_width);
          when "1110" => -- JMP
            ip <= imm;
            ip <= std_logic_vector(unsigned(ip) + 1);

          when "1111" => -- JEQ
            if op1 = op2 then
              ip <= imm;
            else
              ip <= std_logic_vector(unsigned(ip) + 1);
            end if;
            ip <= std_logic_vector(unsigned(ip) + 1);

          when "1000" => -- ADD
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(op1) + unsigned(op2));
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1001" => -- SUB
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(op2) - unsigned(op1));
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1010" => -- NAND
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= not (op1 and op2);
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1011" => -- SLT
            op1 <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2 <= stack(to_integer(sp) - 3 downto to_integer(sp) - data_width - 2);
            op3 <= (others => '0'); -- Clear op3
            if signed(op2) < signed(op1) then
              stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= (others => '1');
            else
              stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= (others => '0');
            end if;
            sp <= sp - to_unsigned(2, addr_width);

          when "1100" => -- SHL
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= (others => '0'); -- Clear op2
            op3                                                          <= (others => '0'); -- Clear op3
            stack(to_integer(sp) - 1 downto to_integer(sp) - data_width) <= std_logic_vector(unsigned(stack(to_integer(sp) - 1 downto to_integer(sp) - data_width)) sll 1);
            sp                                                           <= sp - to_unsigned(2, addr_width);

          when "1101" => -- SHR
            op1                                                          <= stack(to_integer(sp) - 1 downto to_integer(sp) - data_width);
            op2                                                          <= (others => '0'); -- Clear op2
            op3                                                          <= (others => '0'); -- Clear op3
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