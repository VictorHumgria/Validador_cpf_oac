import subprocess
import tkinter as tk
from tkinter import scrolledtext, messagebox, simpledialog

def verificar_digitos_iguais(cpf):
    return all(c == cpf[0] for c in cpf)

def validar_cpfs():
    output_area.delete(1.0, tk.END)
    result = subprocess.run(
        ["java", "-jar", "Mars45.jar", "LeitorArquivo.asm"], 
        capture_output=True, text=True
    )
    output_area.insert(tk.END, "Saída do LeitorArquivo.asm:\n")
    
    # Filtra as mensagens indesejadas
    filtered_output = filtrar_mensagens(result.stdout)
    
    output_area.insert(tk.END, filtered_output)
    lines = result.stdout.splitlines()
    cpfs_lidos = []
    for line in lines:
        line = line.strip()
        if len(line) == 11 and line.isdigit():
            if verificar_digitos_iguais(line):
                output_area.insert(tk.END, f"\n\nCPF inválido (números repetidos): '{line}'\n")
            else:
                cpfs_lidos.append(line)
    
    output_area.insert(tk.END, "\n_____________________\n")
    if cpfs_lidos:
        for cpf_lido in cpfs_lidos:
            output_area.insert(tk.END, f"\nCPF lido: '{cpf_lido}'\n")
            
            mars_path = "Mars45.jar"
            process = subprocess.Popen(
                ["java", "-jar", mars_path, "Validar.asm"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            for char in cpf_lido:
                process.stdin.write(char)
            process.stdin.write('\n')
            process.stdin.close()
            stdout, stderr = process.communicate()
            
            # Filtra as mensagens de entrada da saída de validação
            filtered_stdout = filtrar_mensagens(stdout)
            output_area.insert(tk.END, "Saída do Validar.asm:\n")
            output_area.insert(tk.END, filtered_stdout)
            output_area.insert(tk.END, "_____________________\n")
            if stderr:
                output_area.insert(tk.END, "Erros do Validar.asm:\n")
                output_area.insert(tk.END, stderr)
    else:
        messagebox.showinfo("Resultado", "Nenhum CPF lido ou CPF inválido (números repetidos).")

def validar_cpf_manual():
    cpf_manual = simpledialog.askstring("Entrada de CPF", "Digite um CPF para validar:")
    
    if cpf_manual and len(cpf_manual) == 11 and cpf_manual.isdigit() and not verificar_digitos_iguais(cpf_manual):
        output_area.delete(1.0, tk.END)
        output_area.insert(tk.END, f"CPF inserido manualmente: '{cpf_manual}'\n")
        
        mars_path = "Mars45.jar"
        process = subprocess.Popen(
            ["java", "-jar", mars_path, "Validar.asm"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        for char in cpf_manual:
            process.stdin.write(char)
        process.stdin.write('\n')
        process.stdin.close()
        stdout, stderr = process.communicate()
        
        # Filtra as mensagens de entrada da saída de validação
        filtered_stdout = filtrar_mensagens(stdout)
        output_area.insert(tk.END, "Saída do Validar.asm:\n")
        output_area.insert(tk.END, filtered_stdout)
        if stderr:
            output_area.insert(tk.END, "Erros do Validar.asm:\n")
            output_area.insert(tk.END, stderr)
    else:
        messagebox.showinfo("Erro", "CPF inválido. Insira um CPF com 11 dígitos numéricos e não repetidos.")

# Função para filtrar mensagens indesejadas
def filtrar_mensagens(output):
    linhas_filtradas = []
    for linha in output.splitlines():
        # Filtrar mensagens indesejadas pela palavra-chave ou frase
        if ("MARS 4.5  Copyright 2003-2014 Pete Sanderson and Kenneth Vollmar" not in linha and
            "Digite o CPF (somente numeros):" not in linha):
            linhas_filtradas.append(linha)
    return '\n'.join(linhas_filtradas)

# Configurações da janela principal
janela = tk.Tk()
janela.title("Validador de CPF")
janela.geometry("500x400")
janela.configure(bg="#f0f0f0")

# Botão para validar CPFs lidos do arquivo
botao_validar = tk.Button(janela, text="Validar CPFs", command=validar_cpfs, bg="#4CAF50", fg="white", font=("Arial", 12))
botao_validar.pack(pady=10)

# Botão para validar CPF inserido manualmente
botao_validar_manual = tk.Button(janela, text="Validar CPF Manualmente", command=validar_cpf_manual, bg="#2196F3", fg="white", font=("Arial", 12))
botao_validar_manual.pack(pady=10)

# Área de saída para exibir os resultados
output_area = scrolledtext.ScrolledText(janela, wrap=tk.WORD, width=60, height=15, font=("Arial", 10), bg="#ffffff")
output_area.pack(padx=20, pady=10)

# Iniciar o loop da interface
janela.mainloop()
