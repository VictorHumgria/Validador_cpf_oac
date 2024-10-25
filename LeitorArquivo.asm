.data
    banco:        .asciiz "arq.txt"  # Nome do arquivo a ser lido
    buffer:        .space 2048            # Buffer para armazenar os dados lidos

.text
main:
    # Abrir o arquivo xTrain.txt
    li $v0, 13                    # syscall para abrir arquivo
    la $a0, banco              # carrega o nome do arquivo
    li $a1, 0                     # modo de leitura
    li $a2, 0                     # ignorar permissões
    syscall                        # chamada do sistema
    move $s0, $v0                 # salvando o descritor do arquivo

    # Ler e exibir o conteúdo do arquivo
ler_loop:
    li $v0, 14                    # syscall para ler do arquivo
    move $a0, $s0                 # descritor do arquivo
    la $a1, buffer                # endereço do buffer
    li $a2, 2048                  # quantidade de bytes a ler
    syscall                        # lê do arquivo

    # Verifica se a leitura foi bem-sucedida (número de bytes lidos)
    beqz $v0, fechar_arquivo       # se não leu nada, vai fechar o arquivo

    # Exibir conteúdo lido
    li $v0, 4                     # syscall para imprimir string
    la $a0, buffer                # endereço do buffer
    syscall                        # imprime o buffer

    j ler_loop                     # continuar lendo

fechar_arquivo:
    # Fechar o arquivo
    li $v0, 16                    # syscall para fechar arquivo
    move $a0, $s0                 # descritor do arquivo
    syscall                        # chamada do sistema

    # Finalizar o programa
    li $v0, 10                    # syscall para terminar o programa
    syscall
