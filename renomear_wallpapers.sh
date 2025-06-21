#!/bin/bash

# ==============================================================================
# renomear_wallpapers.sh (v2)
#
# Renomeia arquivos .png e .jpg no diretório para o formato wallpaper<N>.<ext>,
# garantindo que não haja conflitos e ignorando outros tipos de arquivo.
# ==============================================================================

# Etapa 1: Encontrar o maior número já usado nos nomes de arquivo "wallpaper...".
# Isso evita conflitos e permite que o script seja executado várias vezes.
max_num=0
for file in wallpaper[0-9]*.*; do
    # Verifica se o arquivo realmente corresponde ao padrão para evitar erros
    if [[ -f "$file" ]]; then
        # Extrai apenas os dígitos do nome do arquivo usando 'sed'
        num=$(echo "$file" | sed -n 's/^wallpaper\left([0-9]\+\right)\..*$/\1/p')
        
        # Se um número foi extraído e é maior que o máximo atual, atualiza o máximo
        if [[ ! -z "$num" && "$num" -gt "$max_num" ]]; then
            max_num=$num
        fi
    fi
done

# Define o contador inicial para o próximo número disponível
count=$((max_num + 1))

echo "Iniciando a renomeação de arquivos .png e .jpg..."
echo "---"

# Etapa 2: Percorrer todos os arquivos do diretório e renomear os que precisam.
for file in *; do
    # Garante que é um arquivo válido (e não uma pasta, etc.)
    if [[ ! -f "$file" ]]; then
        continue
    fi

    # Pega a extensão do arquivo e a converte para minúsculas
    extension="${file##*.}"
    ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    # --- FILTRO DE EXTENSÃO ---
    # Pula o arquivo se a extensão não for 'png' ou 'jpg'.
    # Também ignora o próprio script.
    if [[ "$ext_lower" != "png" && "$ext_lower" != "jpg" || "$file" == "$(basename "$0")" ]]; then
        continue
    fi

    # Verifica se o arquivo JÁ está no formato wallpaper<N>.<ext>. Se estiver, pula.
    if [[ "$file" =~ ^wallpaper[0-9]+\..+$ ]]; then
        echo "Ignorando arquivo já nomeado: $file"
        continue
    fi

    # Define o novo nome usando a extensão original (para preservar o case, ex: .PNG)
    new_name="wallpaper${count}.${extension}"

    # Renomeia o arquivo e exibe uma mensagem (-v, verbose)
    mv -v -- "$file" "$new_name"

    # Incrementa o contador para o próximo arquivo
    count=$((count + 1))
done

echo "---"
echo "Renomeação concluída!"
