#!/bin/bash

# Função para exibir o menu
show_menu() {
    echo "Selecione uma opção:"
    echo "1) Colocar placa de rede em modo monitor"
    echo "2) Retornar placa de rede ao modo normal"
    echo "3) Sair"
}

# Função para listar as placas de rede
list_network_interfaces() {
    interfaces=($(iwconfig 2>/dev/null | grep 'IEEE' | awk '{print $1}'))
    echo "Placas de rede disponíveis:"
    for i in "${!interfaces[@]}"; do
        echo "$((i+1))) ${interfaces[$i]}"
    done
}

# Função para selecionar uma placa de rede
select_network_interface() {
    list_network_interfaces
    read -p "Escolha o número da placa de rede: " choice
    index=$((choice-1))
    if [[ $index -ge 0 && $index -lt ${#interfaces[@]} ]]; then
        selected_interface=${interfaces[$index]}
        echo "Placa de rede selecionada: $selected_interface"
    else
        echo "Opção inválida. Por favor, escolha novamente."
        select_network_interface
    fi
}

# Função para colocar a placa de rede em modo monitor
start_monitor_mode() {
    select_network_interface
    sudo airmon-ng start "$selected_interface"
    echo "Placa de rede $selected_interface agora está em modo monitor."
}

# Função para retornar a placa de rede ao modo normal
stop_monitor_mode() {
    select_network_interface
    sudo airmon-ng stop "$selected_interface"
    sudo service NetworkManager start
    echo "Placa de rede $selected_interface voltou ao modo normal."
}

# Loop do menu
while true; do
    show_menu
    read -p "Escolha uma opção: " choice
    case $choice in
        1)
            start_monitor_mode
            ;;
        2)
            stop_monitor_mode
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha novamente."
            ;;
    esac
done
