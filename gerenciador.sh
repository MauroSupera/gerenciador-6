#!/bin/bash

# === DESCRIÇÃO ===
# === ENGLISH ===
# Main script for the management system. Verifies managers, assigns permissions,
# and allows language selection. Saves the choice for future runs.
# === PORTUGUÊS ===
# Script principal do sistema de gerenciamento. Verifica gerenciadores, atribui permissões
# e permite a seleção de idioma. Salva a escolha para execuções futuras.
# === ESPAÑOL ===
# Script principal del sistema de gestión. Verifica gestores, asigna permisos,
# y permite la selección de idioma. Guarda la elección para futuras ejecuciones.

# === CORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # Sem cor

# === CONFIGURAÇÕES ===
API="VORTEXUSCLOUD"  # Chave API para validação
GERENCIADORES=("gerenciador_en.sh" "gerenciador_es.sh" "gerenciador_pt.sh")
LINGUA_FILE=".lingua_escolhida"  # Arquivo que salva a escolha da língua

# === VERIFICAÇÃO DO ARQUIVO DE LÍNGUA ===
if [ -f "$LINGUA_FILE" ]; then
    # Caso o arquivo exista, leia a escolha
    LINGUA=$(cat "$LINGUA_FILE")
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${GREEN}A LÍNGUA ESCOLHIDA FOI: ${LINGUA}.${NC}"
    echo -e "${YELLOW}EXECUTANDO O GERENCIADOR...${NC}"
    echo -e "${CYAN}==============================================${NC}"
    case $LINGUA in
        "ENGLISH")
            ./gerenciador_en.sh "$API"
            exit 0
            ;;
        "ESPAÑOL")
            ./gerenciador_es.sh "$API"
            exit 0
            ;;
        "PORTUGUÊS")
            ./gerenciador_pt.sh "$API"
            exit 0
            ;;
        *)
            echo -e "${RED}ERRO: LÍNGUA INVÁLIDA NO ARQUIVO.${NC}"
            rm -f "$LINGUA_FILE"  # Remove o arquivo inválido
            ;;
    esac
fi

# === VERIFICAÇÃO DE GERENCIADORES ===
verificar_gerenciadores() {
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${YELLOW}VERIFICANDO SE TODOS OS GERENCIADORES ESTÃO PRESENTES${NC}"
    for script in "${GERENCIADORES[@]}"; do
        if [ ! -f "$script" ]; then
            echo -e "${RED}ERRO: ${script} NÃO ENCONTRADO.${NC}"
            echo -e "${YELLOW}POR FAVOR, REINSTALE O SISTEMA PARA CONTINUAR.${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}TODOS OS GERENCIADORES FORAM ENCONTRADOS COM SUCESSO.${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === ATRIBUIÇÃO DE PERMISSÕES ===
atribuir_permissoes() {
    echo -e "${CYAN}FORNECENDO PERMISSÕES NECESSÁRIAS PARA OS GERENCIADORES...${NC}"
    for script in "${GERENCIADORES[@]}"; do
        chmod 777 "$script"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}PERMISSÕES ATRIBUÍDAS COM SUCESSO PARA ${script}.${NC}"
        else
            echo -e "${RED}ERRO AO ATRIBUIR PERMISSÕES PARA ${script}.${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}TODAS AS PERMISSÕES FORAM ATRIBUÍDAS COM SUCESSO.${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === ESCOLHER LÍNGUA ===
escolher_lingua() {
    echo -e "${CYAN}BEM-VINDO AO SISTEMA DE GERENCIAMENTO${NC}"
    echo -e "${YELLOW}ESCOLHA O IDIOMA PREFERIDO:${NC}"
    echo -e "${GREEN}1 - ENGLISH${NC}"
    echo -e "${GREEN}2 - ESPAÑOL${NC}"
    echo -e "${GREEN}3 - PORTUGUÊS${NC}"
    read -p "> " LINGUA_ESCOLHIDA

    case $LINGUA_ESCOLHIDA in
        1)
            echo "ENGLISH" > "$LINGUA_FILE"
            ./gerenciador_en.sh "$API"
            ;;
        2)
            echo "ESPAÑOL" > "$LINGUA_FILE"
            ./gerenciador_es.sh "$API"
            ;;
        3)
            echo "PORTUGUÊS" > "$LINGUA_FILE"
            ./gerenciador_pt.sh "$API"
            ;;
        *)
            echo -e "${RED}OPÇÃO INVÁLIDA. TENTE NOVAMENTE.${NC}"
            escolher_lingua
            ;;
    esac
}

# === EXECUÇÃO PRINCIPAL ===
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}INICIANDO O SISTEMA DE GERENCIAMENTO...${NC}"
echo -e "${YELLOW}SE DESEJA ESCOLHER OUTRO IDIOMA, REMOVA O ARQUIVO: ${LINGUA_FILE}${NC}"
echo -e "${CYAN}==============================================${NC}"
verificar_gerenciadores
atribuir_permissoes
escolher_lingua