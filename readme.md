**Modelagem de um hardware em VHDL, denominado SoC : System on a Chip.**


### Um SoC é um dispositivo que contém diversos sub-componentes necessários para o funcionamento de um sistema computacional completo, tais como Processador, memória(s) principal(ais), barramentos, entre outros.

#### O SoC a ser desenvolvido neste projeto está modelado em linguagem de descrição de hardware (VHDL).
Adicionalmente, todas as entidades modeladas possuem, para cada uma, um circuito de teste denominado Testbench, de forma a verificar e validar sua corretude em tempo de simulação.

#### O SoC a ser desenvolvido nesse projeto, contém os seguintes subcomponentes:
1. Um Processador (CPU) capaz de executar um conjunto de instruções;
2. Duas Memórias Principais:
    • Armazenamento por bytes (8 bits);
    • Endere¸cadas por byte;
    • Uma mem´oria somente para armazenamento de instruções;
    • Outra memória somente para armazenamento de dados;
3. Um Codec (codificador/decodificador) capaz de trabalhar com dados
em formato texto, isto é, caracteres ASCII;
