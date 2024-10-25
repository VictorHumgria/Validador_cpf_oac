.data
cpf_input:      .space  15                 # Espaço para entrada do CPF (14 caracteres + '\0')
cpf_digits:     .space  12                 # Espaço para armazenar os dígitos (0 a 9) e DVs calculados
msg_input:      .asciiz "Digite o CPF (somente números): "
msg_valid:      .asciiz "\nCPF válido.\n"
msg_invalid:    .asciiz "\nCPF inválido.\n"
msg_error:      .asciiz "\nEntrada inválida. Certifique-se de digitar 11 dígitos numéricos.\n"

.text
.globl main

main:
    # Solicita ao usuário que digite o CPF
    li $v0, 4                              # syscall: print_string
    la $a0, msg_input
    syscall

    # Lê a entrada do usuário
    li $v0, 8                              # syscall: read_string
    la $a0, cpf_input                      # Buffer para armazenar a entrada
    li $a1, 15                             # Tamanho máximo da entrada
    syscall

    # Processa a entrada para extrair apenas os dígitos numéricos
    la $t0, cpf_input                      # Ponteiro para a entrada
    la $t1, cpf_digits                     # Ponteiro para armazenar os dígitos
    li $t2, 0                              # Contador de dígitos numéricos

process_input:
    lb $t3, 0($t0)                         # Carrega um byte da entrada
    beqz $t3, check_length                 # Se for o fim da string, vai verificar o tamanho
    blt $t3, '0', skip_char                # Se caractere < '0', ignora
    bgt $t3, '9', skip_char                # Se caractere > '9', ignora
    sb $t3, 0($t1)                         # Armazena o dígito numérico em cpf_digits
    addi $t1, $t1, 1                       # Incrementa o ponteiro de cpf_digits
    addi $t2, $t2, 1                       # Incrementa o contador de dígitos
skip_char:
    addi $t0, $t0, 1                       # Próximo caractere da entrada
    j process_input

check_length:
    li $t4, 11
    bne $t2, $t4, input_error              # Se não tiver 11 dígitos, erro

    # Conversão dos caracteres ASCII para números inteiros
    la $t0, cpf_digits                     # Ponteiro para percorrer os dígitos
    li $t1, 0                              # Índice

convert_digits:
    lb $t5, 0($t0)                         # Carrega um dígito como caractere
    sub $t5, $t5, 48                       # Converte de ASCII para número
    sb $t5, 0($t0)                         # Armazena o número convertido
    addi $t0, $t0, 1                       # Próximo dígito
    addi $t1, $t1, 1                       # Incrementa índice
    blt $t1, 11, convert_digits            # Loop para todos os 11 dígitos

    # Armazena os dígitos verificadores fornecidos pelo usuário
    la $t0, cpf_digits                     # Ponteiro para os dígitos
    lb $s1, 9($t0)                         # Primeiro DV fornecido
    lb $s2, 10($t0)                        # Segundo DV fornecido

    # Cálculo do primeiro dígito verificador
    la $t0, cpf_digits                     # Reinicia o ponteiro
    li $t1, 0                              # Índice
    li $t2, 10                             # Peso inicial
    li $t3, 0                              # Soma acumulada

calc_first_digit:
    lb $t4, 0($t0)                         # Carrega o dígito
    mul $t5, $t4, $t2                      # Multiplica pelo peso
    add $t3, $t3, $t5                      # Soma acumulada
    addi $t0, $t0, 1                       # Próximo dígito
    addi $t1, $t1, 1                       # Incrementa índice
    addi $t2, $t2, -1                      # Decrementa peso
    blt $t1, 9, calc_first_digit           # Loop para os 9 primeiros dígitos

    # Calcula o primeiro dígito verificador
    li $t8, 11                             # Divisor
    div $t3, $t8                           # Divide a soma por 11
    mfhi $t6                               # Resto da divisão
    li $t7, 2
    blt $t6, $t7, first_digit_zero
    li $t7, 11
    sub $t6, $t7, $t6                      # 11 - resto
    j store_first_digit
first_digit_zero:
    li $t6, 0

store_first_digit:
    move $s3, $t6                          # Armazena o primeiro DV calculado em $s3

    # Cálculo do segundo dígito verificador
    # Usando os 9 dígitos originais + o primeiro DV calculado
    la $t0, cpf_digits                     # Reinicia o ponteiro
    li $t1, 0                              # Índice
    li $t2, 11                             # Peso inicial
    li $t3, 0                              # Soma acumulada

calc_second_digit:
    blt $t1, 9, continue_second_calc
    beq $t1, 9, use_first_dv
    j calc_second_digit_done
continue_second_calc:
    lb $t4, 0($t0)                         # Carrega o dígito
    j proceed_calc
use_first_dv:
    move $t4, $s3                          # Usa o primeiro DV calculado
proceed_calc:
    mul $t5, $t4, $t2                      # Multiplica pelo peso
    add $t3, $t3, $t5                      # Soma acumulada
    addi $t1, $t1, 1                       # Incrementa índice
    addi $t2, $t2, -1                      # Decrementa peso
    addi $t0, $t0, 1                       # Incrementa o ponteiro apenas se índice < 9
    blt $t1, 10, calc_second_digit         # Loop até índice < 10
calc_second_digit_done:
    li $t8, 11                             # Divisor
    div $t3, $t8                           # Divide a soma por 11
    mfhi $t6                               # Resto da divisão
    li $t7, 2
    blt $t6, $t7, second_digit_zero
    li $t7, 11
    sub $t6, $t7, $t6                      # 11 - resto
    j store_second_digit
second_digit_zero:
    li $t6, 0

store_second_digit:
    move $s4, $t6                          # Armazena o segundo DV calculado em $s4

    # Comparação dos dígitos verificadores fornecidos com os calculados
    # $s1: Primeiro DV fornecido
    # $s2: Segundo DV fornecido
    # $s3: Primeiro DV calculado
    # $s4: Segundo DV calculado

    # Comparação do primeiro dígito verificador
    bne $s1, $s3, cpf_invalid              # Se diferente, CPF inválido

    # Comparação do segundo dígito verificador
    bne $s2, $s4, cpf_invalid              # Se diferente, CPF inválido

    # Se ambos os dígitos coincidem, CPF é válido
    j cpf_valid

cpf_valid:
    li $v0, 4                              # syscall: print_string
    la $a0, msg_valid
    syscall
    j end_program

cpf_invalid:
    li $v0, 4                              # syscall: print_string
    la $a0, msg_invalid
    syscall
    j end_program

input_error:
    li $v0, 4                              # syscall: print_string
    la $a0, msg_error
    syscall
    j end_program

end_program:
    li $v0, 10                             # syscall: exit
    syscall
