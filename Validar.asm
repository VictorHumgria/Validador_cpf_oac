.data
cpf_input:      .space  15                 # Espa�o para entrada do CPF (14 caracteres + '\0')
cpf_digits:     .space  12                 # Espa�o para armazenar os d�gitos (0 a 9) e DVs calculados
msg_input:      .asciiz "Digite o CPF (somente numeros): "
msg_valid:      .asciiz "\nCPF valido.\n"
msg_invalid:    .asciiz "\nCPF invalido.\n"
msg_error:      .asciiz "\nEntrada invalida. Certifique-se de digitar 11 digitos numuricos.\n"

.text
.globl main

main:
    # Solicita ao usu�rio que digite o CPF
    li $v0, 4                              # syscall: print_string
    la $a0, msg_input
    syscall

    # L� a entrada do usu�rio
    li $v0, 8                              # syscall: read_string
    la $a0, cpf_input                      # Buffer para armazenar a entrada
    li $a1, 15                             # Tamanho m�ximo da entrada
    syscall

    # Processa a entrada para extrair apenas os d�gitos num�ricos
    la $t0, cpf_input                      # Ponteiro para a entrada
    la $t1, cpf_digits                     # Ponteiro para armazenar os d�gitos
    li $t2, 0                              # Contador de d�gitos num�ricos

process_input:
    lb $t3, 0($t0)                         # Carrega um byte da entrada
    beqz $t3, check_length                 # Se for o fim da string, vai verificar o tamanho
    blt $t3, '0', skip_char                # Se caractere < '0', ignora
    bgt $t3, '9', skip_char                # Se caractere > '9', ignora
    sb $t3, 0($t1)                         # Armazena o d�gito num�rico em cpf_digits
    addi $t1, $t1, 1                       # Incrementa o ponteiro de cpf_digits
    addi $t2, $t2, 1                       # Incrementa o contador de d�gitos
skip_char:
    addi $t0, $t0, 1                       # Pr�ximo caractere da entrada
    j process_input

check_length:
    li $t4, 11
    bne $t2, $t4, input_error              # Se n�o tiver 11 d�gitos, erro

    # Convers�o dos caracteres ASCII para n�meros inteiros
    la $t0, cpf_digits                     # Ponteiro para percorrer os d�gitos
    li $t1, 0                              # �ndice

convert_digits:
    lb $t5, 0($t0)                         # Carrega um d�gito como caractere
    sub $t5, $t5, 48                       # Converte de ASCII para n�mero
    sb $t5, 0($t0)                         # Armazena o n�mero convertido
    addi $t0, $t0, 1                       # Pr�ximo d�gito
    addi $t1, $t1, 1                       # Incrementa �ndice
    blt $t1, 11, convert_digits            # Loop para todos os 11 d�gitos

    # Armazena os d�gitos verificadores fornecidos pelo usu�rio
    la $t0, cpf_digits                     # Ponteiro para os d�gitos
    lb $s1, 9($t0)                         # Primeiro DV fornecido
    lb $s2, 10($t0)                        # Segundo DV fornecido

    # C�lculo do primeiro d�gito verificador
    la $t0, cpf_digits                     # Reinicia o ponteiro
    li $t1, 0                              # �ndice
    li $t2, 10                             # Peso inicial
    li $t3, 0                              # Soma acumulada

calc_first_digit:
    lb $t4, 0($t0)                         # Carrega o d�gito
    mul $t5, $t4, $t2                      # Multiplica pelo peso
    add $t3, $t3, $t5                      # Soma acumulada
    addi $t0, $t0, 1                       # Pr�ximo d�gito
    addi $t1, $t1, 1                       # Incrementa �ndice
    addi $t2, $t2, -1                      # Decrementa peso
    blt $t1, 9, calc_first_digit           # Loop para os 9 primeiros d�gitos

    # Calcula o primeiro d�gito verificador
    li $t8, 11                             # Divisor
    div $t3, $t8                           # Divide a soma por 11
    mfhi $t6                               # Resto da divis�o
    li $t7, 2
    blt $t6, $t7, first_digit_zero
    li $t7, 11
    sub $t6, $t7, $t6                      # 11 - resto
    j store_first_digit
first_digit_zero:
    li $t6, 0

store_first_digit:
    move $s3, $t6                          # Armazena o primeiro DV calculado em $s3

    # C�lculo do segundo d�gito verificador
    # Usando os 9 d�gitos originais + o primeiro DV calculado
    la $t0, cpf_digits                     # Reinicia o ponteiro
    li $t1, 0                              # �ndice
    li $t2, 11                             # Peso inicial
    li $t3, 0                              # Soma acumulada

calc_second_digit:
    blt $t1, 9, continue_second_calc
    beq $t1, 9, use_first_dv
    j calc_second_digit_done
continue_second_calc:
    lb $t4, 0($t0)                         # Carrega o d�gito
    j proceed_calc
use_first_dv:
    move $t4, $s3                          # Usa o primeiro DV calculado
proceed_calc:
    mul $t5, $t4, $t2                      # Multiplica pelo peso
    add $t3, $t3, $t5                      # Soma acumulada
    addi $t1, $t1, 1                       # Incrementa �ndice
    addi $t2, $t2, -1                      # Decrementa peso
    addi $t0, $t0, 1                       # Incrementa o ponteiro apenas se �ndice < 9
    blt $t1, 10, calc_second_digit         # Loop at� �ndice < 10
calc_second_digit_done:
    li $t8, 11                             # Divisor
    div $t3, $t8                           # Divide a soma por 11
    mfhi $t6                               # Resto da divis�o
    li $t7, 2
    blt $t6, $t7, second_digit_zero
    li $t7, 11
    sub $t6, $t7, $t6                      # 11 - resto
    j store_second_digit
second_digit_zero:
    li $t6, 0

store_second_digit:
    move $s4, $t6                          # Armazena o segundo DV calculado em $s4

    # Compara��o dos d�gitos verificadores fornecidos com os calculados
    # $s1: Primeiro DV fornecido
    # $s2: Segundo DV fornecido
    # $s3: Primeiro DV calculado
    # $s4: Segundo DV calculado

    # Compara��o do primeiro d�gito verificador
    bne $s1, $s3, cpf_invalid              # Se diferente, CPF inv�lido

    # Compara��o do segundo d�gito verificador
    bne $s2, $s4, cpf_invalid              # Se diferente, CPF inv�lido

    # Se ambos os d�gitos coincidem, CPF � v�lido
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
