#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green

# Function to center and color text
print_centered() {
    local input="$1"
    local color="$2"
    local term_width=$(tput cols)
    local text_width=${#input}

    # Strip color codes for width calculation
    local stripped_input=$(echo -e "$input" | sed 's/\x1b\[[0-9;]*m//g')
    local stripped_width=${#stripped_input}

    # Calculate padding
    local pad_width=$(( (term_width - stripped_width) / 2 ))
    local padding=$(printf '%*s' "$pad_width")

    # Print with color and padding
    echo -e "${padding}${color}${input}${Color_Off}"
}

# Defina BANNER_ART aqui

print_banner() {
    # Clear the screen
    clear

    # Print banner art line by line, centered
    while IFS= read -r line; do
        print_centered "$line" "$Red"
    done <<< "$BANNER_ART"

    # Print information text, centered
    print_centered "Automatiza AI" "$Green"
    print_centered "Compartilhar, vender ou fornecer essa solução" "$Green"
    print_centered "sem autorização é crime previsto no artigo 184" "$Green"
    print_centered "do código penal que descreve a conduta criminosa" "$Green"
    print_centered "de infringir os direitos autorais da Automatiza AI." "$Green"
    print_centered "PIRATEAR ESSA SOLUÇÃO É CRIME." "$Green"
    print_centered "© Automatiza AI" "$Green"

    # Ensure the color settings are reset
    echo -e "$Color_Off"
}

# Chame a função print_banner aqui, se necessário
