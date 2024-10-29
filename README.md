Aqui está o README completo, com todos os arquivos mencionados, desde a interface em Python até os arquivos em Assembly:
## Link do Vídeo do Projeto
<a href="https://drive.google.com/file/d/1H5_oS_gc0EYSSIMyz1sMAOAMZcwXp7zK/view?usp=drive_link" target="_blank">Clique aqui para acessar o vídeo do projeto</a>

---

# Validador de CPF em Assembly

Este projeto consiste em um sistema completo para validar CPFs utilizando Assembly, incluindo uma interface Python opcional para facilitar a execução e controle. O objetivo é validar números de CPF contidos em um arquivo de entrada, utilizando o algoritmo para cálculo de dígitos verificadores.

## Estrutura do Projeto

- **main.py**: Interface em Python para facilitar o controle da execução e visualização dos resultados da validação de CPF.
- **Mars45.jar**: Simulador MARS, necessário para executar os arquivos Assembly do projeto.
- **Validar.asm**: Código Assembly que realiza a validação dos números de CPF.
- **LeitorArquivo.asm**: Código Assembly que lê os números de CPF contidos em um arquivo de texto e prepara para validação.
- **arq.txt**: Arquivo de entrada contendo números de CPF para validação. Cada linha do arquivo representa um CPF.

## Funcionamento do Sistema

1. **Interface de Controle**:
   - `main.py` atua como uma interface opcional para auxiliar no controle da execução, especialmente útil para organizar a sequência de passos e visualização do status de validação dos CPFs.

2. **Simulador MARS**:
   - `Mars45.jar` é o simulador de Assembly MIPS utilizado para compilar e executar os arquivos Assembly (`Validar.asm` e `LeitorArquivo.asm`).

3. **Validação do CPF**:
   - `Validar.asm` contém o algoritmo de verificação dos dígitos finais do CPF, confirmando a validade do número.

4. **Leitura de Arquivo**:
   - `LeitorArquivo.asm` abre o arquivo `arq.txt`, lê os CPFs e os direciona para o processo de validação.

## Pré-requisitos

Para executar o projeto, você precisará de:
- [MARS MIPS Simulator](http://courses.missouristate.edu/kenvollmar/mars/) para rodar os arquivos Assembly.
- Python 3.x (opcional, caso deseje utilizar `main.py` para facilitar a execução).

## Como Executar

1. **Interface Python** (opcional):
   - Execute `main.py` com `python main.py` para iniciar a interface de controle e visualização dos processos.
   - A interface fornece uma maneira de organizar e acompanhar a execução dos módulos Assembly.

2. **Execução dos Arquivos Assembly**:
   - Abra o `Mars45.jar`, carregue `Validar.asm` e `LeitorArquivo.asm`.
   - Certifique-se de que o simulador está configurado para ler `arq.txt` como entrada e execute os arquivos para validar os CPFs.

3. **Configuração do Arquivo de Entrada**:
   - No arquivo `arq.txt`, insira um CPF por linha. Os CPFs devem estar no formato numérico para serem processados e validados corretamente pelo programa.

## Exemplo de Uso

1. Insira CPFs no arquivo `arq.txt`, seguindo o formato correto (apenas números).
2. Utilize o `main.py` para iniciar a execução, ou carregue manualmente `Validar.asm` e `LeitorArquivo.asm` no simulador MARS para processar os CPFs.
3. O sistema exibirá o status de cada CPF, indicando se é válido ou não com base nos dígitos verificadores.

## Autores e Contribuições

Este projeto foi desenvolvido como parte de um trabalho acadêmico, e contribuições são bem-vindas. Sinta-se à vontade para enviar sugestões e pull requests!

--- 
criadores: 
        - JOAO VICTOR SILVA DE HUNGRIA
        - RENNE BISPO DOS SANTOS
        - TALYSSON FELIPE VASCONCELOS SANTOS
