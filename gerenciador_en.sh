#!/bin/bash

# === ANSI COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No color

# === CONFIGURATION ===
# Configuration for the expected API. This is the key used to validate the connection with the main manager.
API_EXPECTED="VORTEXUSCLOUD"

# === FUNCTION TO VALIDATE THE API ===
# This function checks if the API provided by the main manager matches the expected key.
# If it doesn't match, the script displays an error message and exits.
# The user should not modify this function unless they understand how the validation system works.
validate_api() {
    API_RECEIVED=$1
    if [ "$API_RECEIVED" != "$API_EXPECTED" ]; then
        echo -e "${RED}API CANNOT CONNECT TO THE GERENCIADOR.SH FILE.${NC}"
        echo -e "${YELLOW}PLEASE PROVIDE THE CONFIGURATION FILE TO EXECUTE THIS FILE.${NC}"
        echo -e "${YELLOW}IF YOU DON'T KNOW, CONTACT OUR SUPPORT:${NC}"
        echo -e "${CYAN}HTTPS://VORTEXCLOUD.COM.BR${NC}"
        exit 1
    fi
}

# === INITIALIZING MANAGER ===
# Validates the provided API and, if correct, starts the systems. The user can add
# custom commands after the validation, if necessary.
echo -e "${CYAN}==============================================${NC}"
echo -e "${YELLOW}VALIDATING API...${NC}"
validate_api "$1"
echo -e "${GREEN}API CONNECTED SUCCESSFULLY! SYSTEMS VALIDATED.${NC}"
echo -e "${CYAN}==============================================${NC}"

# === BELOW START EXECUTING THE SCRIPT BUT FIRST CHECK THE HOSTNAMES AND IPS ===

# ###########################################
# Configurações da whitelist
# This section defines the authorized hostnames and IPs.
# Edit the arrays below to include the allowed hostnames and IPs for your project.
# ###########################################
WHITELIST_HOSTNAMES=("app.vexufy.com")
WHITELIST_IPS=("199.85.209.85" "199.85.209.109")
VALIDATED=false  # Flag to check if the environment has already been validated

# ###########################################
# Função para obter IPs privados e públicos
# This function retrieves the machine's private IP and tries to fetch the public IP 
# using multiple online services. Ensure the system has internet access.
# ###########################################
obter_ips() {
    # Obter o IP privado
    IP_PRIVADO=$(hostname -I | awk '{print $1}')
    
    # Obter o IP público usando alternativas
    IP_PUBLICO=""
    SERVICOS=("ifconfig.me" "api64.ipify.org" "ipecho.net/plain")
    
    for SERVICO in "${SERVICOS[@]}"; do
        IP_PUBLICO=$(curl -s --max-time 5 "http://${SERVICO}")
        if [[ $IP_PUBLICO =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        fi
    done

    # Verifica se conseguiu obter o IP público
    if [ -z "$IP_PUBLICO" ]; then
        IP_PUBLICO="Unable to fetch the public IP"
    fi

    echo "$IP_PRIVADO" "$IP_PUBLICO"
}

# ###########################################
# Função para validar ambiente
# This function verifies whether the current environment is authorized
# by checking the private or public IP against the whitelist.
# ###########################################
validar_ambiente() {
    # Exibição de validação inicial
    echo -e "\033[1;36m======================================"
    echo -e "       VALIDATING ENVIRONMENT..."
    echo -e "======================================\033[0m"
    sleep 2  # Simulate validation process

    # Obter IPs públicos e privados
    read -r IP_PRIVADO IP_PUBLICO <<<"$(obter_ips)"

    # Resolver IPs associados aos hostnames na whitelist
    for HOSTNAME in "${WHITELIST_HOSTNAMES[@]}"; do
        RESOLVIDOS=$(getent ahosts "$HOSTNAME" | awk '{print $1}' | sort -u)
        WHITELIST_IPS+=($RESOLVIDOS)
    done

    # Mostrar informações coletadas
    echo -e "\033[1;33mCurrent hostname: $(hostname)"
    echo -e "Current private IP: $IP_PRIVADO"
    echo -e "Current public IP: $IP_PUBLICO"
    echo -e "======================================\033[0m"
    sleep 3  # Allow the user to review the information

    # Verificar IP privado
    if [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PRIVADO} " ]] || [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PUBLICO} " ]]; then
        echo -e "\033[1;32m✔ Environment successfully validated! Proceeding...\033[0m"
        VALIDATED=true
        return 0
    fi

    # Mensagem de erro
    while true; do
        clear
        echo -e "\033[1;31m======================================"
        echo -e "❌ ERROR: UNAUTHORIZED ENVIRONMENT"
        echo -e "--------------------------------------"
        echo -e "⚠️  This system is not licensed for external use."
        echo -e "⚠️  Using this system outside authorized servers is strictly prohibited."
        echo -e "--------------------------------------"
        echo -e "➡️  Current hostname: $(hostname)"
        echo -e "➡️  Current private IP: $IP_PRIVADO"
        echo -e "➡️  Current public IP: $IP_PUBLICO"
        echo -e "--------------------------------------"
        echo -e "✅ Authorized servers: ${WHITELIST_HOSTNAMES[*]}"
        echo -e "✅ Authorized IPs: ${WHITELIST_IPS[*]}"
        echo -e "--------------------------------------"
        echo -e "💡 To purchase a license or hosting services:"
        echo -e "   🌐 Visit: \033[1;34mhttps://vortexuscloud.com.br\033[0m"
        echo -e "======================================\033[0m"
        sleep 10
    done
}

# ###########################################
# Função de validação secundária
# This function revalidates the environment in subsequent operations.
# ###########################################
validar_secundario() {
    echo -e "\033[1;36mRevalidating environment...\033[0m"
    sleep 2
    validar_ambiente
}

# ###########################################
# Verificar whitelist antes de qualquer operação
# Ensure the environment is validated before performing any operations.
# ###########################################
if [ "$VALIDATED" = false ]; then
    validar_ambiente
fi

# Simular validações em execuções subsequentes
echo -e "\033[1;36mWelcome to the authorized system! Preparing for subsequent validations...\033[0m"
sleep 5
validar_secundario

# ###########################################
# Início do script principal
# The main script starts here after the environment is validated.
# ###########################################
echo -e "\033[1;32m======================================"
echo -e "    Authorized and operational system!"
echo -e "======================================\033[0m"

# ###########################################
# Main Configurations
# This section contains key configurations for the script.
# - BASE_DIR: Directory where main files are stored. Edit as needed.
# - NUM_AMBIENTES: Number of environments to simulate or configure.
# - TERMS_FILE: File used to store the acceptance of terms. Edit if necessary.
# ###########################################
BASE_DIR="/home/container"
NUM_AMBIENTES=8
TERMS_FILE="${BASE_DIR}/termos_accepted.txt"

# ###########################################
# ANSI Colors
# These are the color codes used for text styling in terminal outputs.
# Edit these colors if you need to customize the display theme.
# ###########################################
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No color

# ###########################################
# Animation Function
# This function displays a given text character by character, simulating an animation.
# Edit the 'delay' variable to increase or decrease animation speed.
# ###########################################
anima_texto() {
    local texto="$1"
    local delay=0.1
    for (( i=0; i<${#texto}; i++ )); do
        printf "${YELLOW}${texto:$i:1}${NC}"
        sleep "$delay"
    done
    echo ""
}

# ###########################################
# Function to display the 3D billboard with static text below
# This function creates a 3D text display in the terminal. The text, footer, and links
# can be edited for your project. Ensure the terminal supports ANSI escape sequences.
# ###########################################
exibir_outdoor_3D() {
    clear
    local width=$(tput cols)  # Terminal width
    local height=$(tput lines)  # Terminal height
    local start_line=$(( height / 3 ))
    local start_col=$(( (width - 60) / 2 ))  # Center the text

    # 3D art of the main text
    local outdoor_text=(
        " _   _  ___________ _____ _______   ___   _ _____ "
        "| | | ||  _  | ___ \\_   _|  ___\\ \\ / / | | /  ___|"
        "| | | || | | | |_/ / | | | |__  \\ V /| | | \\ --. "
        "| | | || | | |    /  | | |  __| /   \\| | | |--. \\"
        "\\ \\_/ /\\ \\_/ / |\\ \\  | | | |___/ /^\\ \\ |_| /\\__/ /"
        " \\___/  \\___/\\_| \\_| \\_/ \\____/\\/   \\/\\___/\\____/ "
    )

    # Display the 3D text centered
    for i in "${!outdoor_text[@]}"; do
        tput cup $((start_line + i)) $start_col
        echo -e "${CYAN}${outdoor_text[i]}${NC}"
    done

    # Display "Created by Mauro Gashfix" below the 3D text
    local footer="Created by Mauro Gashfix"
    tput cup $((start_line + ${#outdoor_text[@]} + 1)) $(( (width - ${#footer}) / 2 ))
    echo -e "${YELLOW}${footer}${NC}"

    # Display links below the footer
    local links="vortexuscloud.com.br & vortexuscloud.com"
    tput cup $((start_line + ${#outdoor_text[@]} + 2)) $(( (width - ${#links}) / 2 ))
    echo -e "${GREEN}${links}${NC}"

    # Display the initialization bar below the links
    local progress_bar="Initializing..."
    tput cup $((start_line + ${#outdoor_text[@]} + 4)) $(( (width - ${#progress_bar} - 20) / 2 ))
    echo -ne "${CYAN}${progress_bar}${NC}"
    for i in $(seq 1 20); do
        echo -ne "${GREEN}#${NC}"
        sleep 0.1
    done
    echo ""
}

# ###########################################
# Function to display terms of service
# This function shows the terms of service and checks if the user has accepted them.
# - TERMS_FILE: File storing the acceptance status. Edit to match your project.
# - Messages: Update the terms messages to suit your service requirements.
# ###########################################
exibir_termos() {
    exibir_outdoor_3D
    sleep 1
    echo -e "${BLUE}This system is authorized only on the Vortexus Cloud platform.${NC}"
    echo -e "${CYAN}======================================${NC}"

    if [ ! -f "$TERMS_FILE" ]; then
        while true; do
            echo -e "${YELLOW}DO YOU ACCEPT THE TERMS OF SERVICE? (YES/NO)${NC}"
            read -p "> " ACEITE
            if [ "$ACEITE" = "yes" ]; then
                echo -e "${GREEN}Terms accepted on $(date).${NC}" > "$TERMS_FILE"
                echo -e "${CYAN}======================================${NC}"
                echo -e "${GREEN}TERMS ACCEPTED. PROCEEDING...${NC}"
                break
            elif [ "$ACEITE" = "no" ]; then
                echo -e "${RED}YOU MUST ACCEPT THE TERMS TO CONTINUE.${NC}"
            else
                echo -e "${RED}INVALID OPTION. TYPE 'YES' OR 'NO'.${NC}"
            fi
        done
    else
        echo -e "${GREEN}TERMS ALREADY ACCEPTED PREVIOUSLY. PROCEEDING...${NC}"
    fi
}




# ###########################################
# Function to create environment folders
# This function creates folders for each environment.
# - Purpose: Creates a directory for each environment to organize related files.
# - Edit: You can edit the "AMBIENTE_PATH" to change the folder names as they are created.
# - Do not edit: The loop and logic for creating folders should not be changed.
# ###########################################
criar_pastas() {
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"  # You can rename "ambiente" to suit your project
        if [ ! -d "$AMBIENTE_PATH" ]; then
            mkdir -p "$AMBIENTE_PATH"
            echo -e "${GREEN}ENVIRONMENT FOLDER ${i} CREATED.${NC}"
        fi
    done
}

# ###########################################
# Update environment status
# - Purpose: Updates the status (e.g., ON/OFF) of a specific environment by writing it to a file.
# - Edit: Only edit the text in the echo commands to suit your project.
# - Do not edit: The logic for writing to the "status" file must remain unchanged.
# ###########################################
atualizar_status() {
    AMBIENTE_PATH=$1
    NOVO_STATUS=$2
    echo "$NOVO_STATUS" > "${AMBIENTE_PATH}/status"  # Writes the new status to a file
    echo -e "${CYAN}Environment status updated to: ${GREEN}${NOVO_STATUS}${NC}"
}

# ###########################################
# Retrieve environment status
# - Purpose: Reads the status (e.g., ON/OFF) of a specific environment.
# - Edit: Only edit the text in the echo commands if needed.
# - Do not edit: The logic for checking and returning the "status" file must not be changed.
# ###########################################
recuperar_status() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/status" ]; then
        cat "${AMBIENTE_PATH}/status"  # Reads the status from the file
    else
        echo "OFF"  # Default status if no file exists
    fi
}

# ###########################################
# Check and restart background sessions
# - Purpose: Verifies and restarts background sessions for each environment if needed.
# - Edit: You can modify the echo texts to suit your project requirements.
# - Do not edit: The logic for handling sessions and commands should not be changed.
# ###########################################
verificar_sessoes() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "CHECKING BACKGROUND SESSIONS..."
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ -f "${AMBIENTE_PATH}/.session" ]; then
            STATUS=$(recuperar_status "$AMBIENTE_PATH")
            if [ "$STATUS" = "ON" ]; then
                COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                
                if [ -n "$COMANDO" ]; then
                    echo -e "${YELLOW}Executing background session for environment ${i}...${NC}"
                    pkill -f "$COMANDO" 2>/dev/null
                    cd "$AMBIENTE_PATH" || continue
                    nohup $COMANDO > nohup.out 2>&1 &
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}BACKGROUND SESSION ACTIVE FOR ENVIRONMENT ${i}.${NC}"
                    else
                        echo -e "${RED}Error while trying to activate session in environment ${i}.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Empty command found in the .session file for environment ${i}.${NC}"
                fi
            else
                echo -e "${RED}Environment ${i} is OFF. Skipping...${NC}"
            fi
        else
            echo -e "${RED}No .session file found for environment ${i}.${NC}"
        fi
    done
    echo -e "${CYAN}======================================${NC}"
}

# ###########################################
# Main menu function
# - Purpose: Displays the main menu and allows users to select an environment to manage.
# - Edit: You can change the echo texts and menu options to fit your project.
# - Do not edit: The logic for handling menu input and calling functions must remain unchanged.
# ###########################################
menu_principal() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       ENVIRONMENT MANAGEMENT"
    echo -e "${CYAN}======================================${NC}"
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        echo -e "${YELLOW}ENVIRONMENT ${i}:${NC} ${GREEN}STATUS - $STATUS${NC}"
    done
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}CHOOSE AN ENVIRONMENT TO MANAGE (1-${NUM_AMBIENTES}):${NC}"
    echo -e "${RED}0 - EXIT${NC}"
    read -p "> " AMBIENTE_ESCOLHIDO

    if [ "$AMBIENTE_ESCOLHIDO" -ge 1 ] && [ "$AMBIENTE_ESCOLHIDO" -le "$NUM_AMBIENTES" ]; then
        gerenciar_ambiente "$AMBIENTE_ESCOLHIDO"
    elif [ "$AMBIENTE_ESCOLHIDO" = "0" ]; then
        anima_texto "EXITING..."
        exit 0
    else
        echo -e "${RED}INVALID CHOICE. TRY AGAIN.${NC}"
        menu_principal
    fi
}

# ###########################################
# Function to choose a pre-configured bot from Vortexus
# - Purpose: Allows users to select pre-configured bots based on language.
# - Edit: You can add or remove language options and adjust the echo texts.
# - Do not edit: The logic for handling bot selection must remain unchanged.
# ###########################################
escolher_bot_pronto() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       CHOOSE PRE-CONFIGURED BOT"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - BOTS IN PORTUGUESE${NC}"
    echo -e "${YELLOW}2 - BOTS IN SPANISH${NC}"
    echo -e "${RED}0 - BACK${NC}"
    read -p "> " OPCAO_BOT

    case $OPCAO_BOT in
        1)
            listar_bots "$AMBIENTE_PATH" "portugues"
            ;;
        2)
            listar_bots "$AMBIENTE_PATH" "espanhol"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Function to list available bots
# - Purpose: Displays a list of pre-configured bots based on the selected language.
# - Edit: Add or modify the bot repositories in the "BOTS" arrays to include new bots.
# - Do not edit: The logic for handling bot selection and repository URLs must remain unchanged.
# ###########################################
listar_bots() {
    AMBIENTE_PATH=$1
    LINGUA=$2
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       AVAILABLE BOTS - ${LINGUA^^}"
    echo -e "${CYAN}======================================${NC}"

    # Structure for available bots
    if [ "$LINGUA" = "portugues" ]; then
        BOTS=(
            "BLACK BOT - https://github.com/MauroSupera/blackbot.git"
            "YOSHINO BOT - https://github.com/MauroSupera/yoshinobot.git"
            "MIKASA ASCENDANCY V3 - https://github.com/maurogashfix/MikasaAscendancyv3.git"
            "INATSUKI BOT - https://github.com/MauroSupera/inatsukibot.git"
            "ESDEATH BOT - https://github.com/Salientekill/ESDEATHBOT.git"
            "CHRIS BOT - https://github.com/MauroSupera/chrisbot.git"
            "TAIGA BOT - https://github.com/MauroSupera/TAIGA-BOT3.git"
            "AGATHA BOT - https://github.com/MauroSupera/agathabotnew.git"
        )
    elif [ "$LINGUA" = "espanhol" ]; then
        BOTS=(
            "GATA BOT - https://github.com/GataNina-Li/GataBot-MD.git"
            "GATA BOT LITE - https://github.com/GataNina-Li/GataBotLite-MD.git"
            "KATASHI BOT - https://github.com/KatashiFukushima/KatashiBot-MD.git"
            "CURIOSITY BOT - https://github.com/AzamiJs/CuriosityBot-MD.git"
            "NOVA BOT - https://github.com/elrebelde21/NovaBot-MD.git"
            "MEGUMIN BOT - https://github.com/David-Chian/Megumin-Bot-MD"
            "YAEMORI BOT - https://github.com/OfcKing/SenkoBot-MD"
            "THEMYSTIC BOT - https://github.com/BrunoSobrino/TheMystic-Bot-MD.git"
        )
    fi

    for i in "${!BOTS[@]}"; do
        echo -e "${GREEN}$((i+1)) - ${BOTS[$i]%% -*}${NC}"
    done
    echo -e "${RED}0 - BACK${NC}"

    read -p "> " BOT_ESCOLHIDO

    if [ "$BOT_ESCOLHIDO" -ge 1 ] && [ "$BOT_ESCOLHIDO" -le "${#BOTS[@]}" ]; then
        REPOSITORIO="${BOTS[$((BOT_ESCOLHIDO-1))]#*- }"
        verificar_instalacao_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    elif [ "$BOT_ESCOLHIDO" = "0" ]; then
        escolher_bot_pronto "$AMBIENTE_PATH"
    else
        echo -e "${RED}Invalid option.${NC}"
        listar_bots "$AMBIENTE_PATH" "$LINGUA"
    fi
}

# ###########################################
# Logic for adding more bots or languages
# - To add a new language:
#   1. Create a new "elif" block like the ones above.
#   2. Set the "BOTS" array with bot names and repository URLs.
#   3. Use the same structure: "BOT NAME - REPOSITORY URL".
# - To add more types of bots in existing languages:
#   1. Add the new bot details to the respective "BOTS" array.
#   2. Ensure the repository URL is correct and accessible.
# ###########################################

# ###########################################
# Function to check bot installation
# - Purpose: Verifies if a bot is already installed in the environment.
# - Edit: You can modify the echo texts to match your project's tone.
# - Do not edit: The logic for checking and installing bots must remain unchanged.
# ###########################################
verificar_instalacao_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}A bot is already installed in this environment.${NC}"
        echo -e "${YELLOW}Do you want to remove the existing bot to install the new one? (yes/no)${NC}"
        read -p "> " RESPOSTA
        if [ "$RESPOSTA" = "yes" ]; then
            remover_bot "$AMBIENTE_PATH"
            instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
        else
            echo -e "${RED}Returning to the main menu...${NC}"
            menu_principal
        fi
    else
        instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    fi
}

# ###########################################
# Function to install a new bot
# - Purpose: Clones the repository of the selected bot into the environment.
# - Edit: Only modify echo texts or error messages as needed.
# - Do not edit: The git cloning logic and directory structure must remain intact.
# ###########################################
instalar_novo_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    NOME_BOT=$(basename "$REPOSITORIO" .git)
    echo -e "${CYAN}Starting installation of bot: ${GREEN}$NOME_BOT${NC}..."
    git clone "$REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bot $NOME_BOT successfully installed in environment $AMBIENTE_PATH!${NC}"
        verificar_node_modules "$AMBIENTE_PATH"
    else
        echo -e "${RED}Error cloning the repository for bot $NOME_BOT. Verify the URL and try again.${NC}"
    fi
}

# ###########################################
# Function to verify and install node_modules
# - Purpose: Ensures all required modules for the bot are installed.
# - Edit: Modify echo texts or installation commands if needed (npm or yarn).
# - Do not edit: The logic for detecting and installing modules should not change.
# ###########################################
verificar_node_modules() {
    AMBIENTE_PATH=$1
    if [ ! -d "${AMBIENTE_PATH}/node_modules" ]; then
        echo -e "${YELLOW}Modules not installed for this bot.${NC}"
        echo -e "${YELLOW}Choose an option to install:${NC}"
        echo -e "${GREEN}1 - npm install${NC}"
        echo -e "${GREEN}2 - yarn install${NC}"
        echo -e "${RED}0 - Back${NC}"
        read -p "> " OPCAO_MODULOS
        case $OPCAO_MODULOS in
            1)
                echo -e "${CYAN}Installing modules with npm...${NC}"
                cd "$AMBIENTE_PATH" && npm install
                [ $? -eq 0 ] && echo -e "${GREEN}Modules successfully installed!${NC}" || echo -e "${RED}Error installing modules with npm.${NC}"
                ;;
            2)
                echo -e "${CYAN}Installing modules with yarn...${NC}"
                cd "$AMBIENTE_PATH" && yarn install
                [ $? -eq 0 ] && echo -e "${GREEN}Modules successfully installed!${NC}" || echo -e "${RED}Error installing modules with yarn.${NC}"
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Invalid option.${NC}"
                verificar_node_modules "$AMBIENTE_PATH"
                ;;
        esac
    else
        echo -e "${GREEN}All required modules are already installed.${NC}"
    fi
    pos_clone_menu "$AMBIENTE_PATH"
}


# ###########################################
# Function to remove the current bot
# - Purpose: Removes all files from the environment folder, effectively uninstalling the bot.
# - Edit: Only modify the echo texts if needed.
# - Do not edit: The logic for file removal and confirmation should not be changed.
# ###########################################
remover_bot() {
    AMBIENTE_PATH=$1

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Bot detected in this environment.${NC}"
        echo -e "${RED}Do you really want to remove the current bot? (yes/no)${NC}"
        read -p "> " CONFIRMAR
        if [ "$CONFIRMAR" = "yes" ]; then
            find "$AMBIENTE_PATH" -mindepth 1 -exec rm -rf {} + 2>/dev/null
            [ -z "$(ls -A "$AMBIENTE_PATH")" ] && echo -e "${GREEN}Bot successfully removed.${NC}" || echo -e "${RED}Error removing the bot.${NC}"
        else
            echo -e "${RED}Removal canceled.${NC}"
        fi
    else
        echo -e "${RED}No bot found in this environment.${NC}"
    fi
    menu_principal
}

# ###########################################
# Function to clone a repository
# - Purpose: Clones a public or private repository into the environment folder.
# - Edit: Adjust echo texts to match your project's tone if necessary.
# - Do not edit: The logic for cloning repositories and handling inputs must remain unchanged.
# ###########################################
clonar_repositorio() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       CLONE REPOSITORY"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Clone public repository${NC}"
    echo -e "${YELLOW}2 - Clone private repository${NC}"
    echo -e "${RED}0 - Back${NC}"
    read -p "> " OPCAO_CLONAR

    case $OPCAO_CLONAR in
        1)
            echo -e "${CYAN}Provide the URL of the public repository:${NC}"
            read -p "> " URL_REPOSITORIO
            if [[ $URL_REPOSITORIO != https://github.com/* ]]; then
                echo -e "${RED}Invalid URL!${NC}"
                clonar_repositorio "$AMBIENTE_PATH"
                return
            fi
            echo -e "${CYAN}Cloning public repository...${NC}"
            git clone "$URL_REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}Repository cloned successfully!${NC}" || echo -e "${RED}Error cloning the repository.${NC}"
            ;;
        2)
            echo -e "${CYAN}Provide the URL of the private repository:${NC}"
            read -p "> " URL_REPOSITORIO
            echo -e "${CYAN}GitHub Username:${NC}"
            read -p "> " USERNAME
            echo -e "${CYAN}Provide the access token:${NC}"
            read -s -p "> " TOKEN
            echo
            GIT_URL="https://${USERNAME}:${TOKEN}@$(echo $URL_REPOSITORIO | cut -d/ -f3-)"
            echo -e "${CYAN}Cloning private repository...${NC}"
            git clone "$GIT_URL" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}Private repository cloned successfully!${NC}" || echo -e "${RED}Error cloning the private repository.${NC}"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Post-clone menu function
# - Purpose: Provides options to execute the bot, install modules, or return to the main menu.
# - Edit: Adjust the echo texts for clarity or add more options if needed.
# - Do not edit: The logic for handling menu selections and calling respective functions.
# ###########################################
pos_clone_menu() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "WHAT DO YOU WANT TO DO NOW?"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Run the bot${NC}"
    echo -e "${YELLOW}2 - Install modules${NC}"
    echo -e "${RED}0 - Back to main menu${NC}"
    read -p "> " OPCAO_POS_CLONE

    case $OPCAO_POS_CLONE in
        1)
            iniciar_bot "$AMBIENTE_PATH"
            ;;
        2)
            instalar_modulos "$AMBIENTE_PATH"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Function to install modules
# - Purpose: Installs necessary modules using npm or yarn in the selected environment.
# - Edit: You can modify echo texts to guide users on module installation options.
# - Do not edit: The logic for executing npm or yarn commands must remain unchanged.
# ###########################################
instalar_modulos() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "INSTALL MODULES"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Install with npm install${NC}"
    echo -e "${YELLOW}2 - Install with yarn install${NC}"
    echo -e "${RED}0 - Back to main menu${NC}"
    read -p "> " OPCAO_MODULOS

    case $OPCAO_MODULOS in
        1)
            echo -e "${CYAN}Installing modules with npm...${NC}"
            cd "$AMBIENTE_PATH" && npm install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Modules installed successfully!${NC}"
            else
                echo -e "${RED}Error installing modules with npm.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        2)
            echo -e "${CYAN}Installing modules with yarn...${NC}"
            cd "$AMBIENTE_PATH" && yarn install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Modules installed successfully!${NC}"
            else
                echo -e "${RED}Error installing modules with yarn.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            instalar_modulos "$AMBIENTE_PATH"
            ;;
    esac
}

# Função para iniciar o bot
iniciar_bot() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        if [ "$STATUS" = "OFF" ]; then
            echo -e "${YELLOW}Existing session with status OFF.${NC}"
            echo -e "${YELLOW}1 - Restart the bot${NC}"
            echo -e "${RED}0 - Back${NC}"
            read -p "> " OPCAO_EXISTENTE
            case $OPCAO_EXISTENTE in
                1)
                    COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                    nohup sh -c "cd $AMBIENTE_PATH && $COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &
                    clear
                    atualizar_status "$AMBIENTE_PATH" "ON"
                    echo -e "${GREEN}Bot successfully restarted!${NC}"
                    menu_principal
                    ;;
                0)
                    menu_principal
                    ;;
                *)
                    echo -e "${RED}Invalid option.${NC}"
                    iniciar_bot "$AMBIENTE_PATH"
                    ;;
            esac
        elif [ "$STATUS" = "ON" ]; then
            echo -e "${RED}There is already an active session in this environment.${NC}"
            echo -e "${RED}Please end the current session before starting another.${NC}"
            echo -e "${YELLOW}0 - Back${NC}"
            read -p "> " OPCAO
            [ "$OPCAO" = "0" ] && menu_principal
        fi
    else
        echo -e "${CYAN}Choose how you want to start the bot:${NC}"
        echo -e "${YELLOW}1 - npm start${NC}"
        echo -e "${YELLOW}2 - Specify a file (e.g., index.js or start.sh)${NC}"
        echo -e "${YELLOW}3 - Install modules and run the bot${NC}"
        echo -e "${RED}0 - Back${NC}"
        read -p "> " INICIAR_OPCAO

        case $INICIAR_OPCAO in
            1)
                echo "npm start" > "${AMBIENTE_PATH}/.session"
                clear
                echo -e "${YELLOW}Restart the server once finished to apply changes${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    cd "$AMBIENTE_PATH" && npm start
                    echo -e "${YELLOW}1 - Restart the bot${NC}"
                    echo -e "${YELLOW}2 - Save and go back to the main menu${NC}"
                    echo -e "${RED}0 - Back${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Restarting the process...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Saving and returning to the main menu...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Invalid option.${NC}"
                            ;;
                    esac
                done
                ;;
            2)
                echo -e "${YELLOW}Enter the name of the file to execute:${NC}"
                read ARQUIVO
                if [[ $ARQUIVO == *.sh ]]; then
                    echo "sh $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                else
                    echo "node $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                fi
                clear
                echo -e "${YELLOW}Restart the server once finished to apply changes${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    if [[ $ARQUIVO == *.sh ]]; then
                        cd "$AMBIENTE_PATH" && sh "$ARQUIVO"
                    else
                        cd "$AMBIENTE_PATH" && node "$ARQUIVO"
                    fi
                    echo -e "${YELLOW}1 - Restart the bot${NC}"
                    echo -e "${YELLOW}2 - Save and go back to the main menu${NC}"
                    echo -e "${RED}0 - Back${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Restarting the process...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Saving and returning to the main menu...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Invalid option.${NC}"
                            ;;
                    esac
                done
                ;;
            3)
                verificar_node_modules "$AMBIENTE_PATH"
                if [ $? -eq 0 ]; then
                    echo "npm start" > "${AMBIENTE_PATH}/.session"
                    cd "$AMBIENTE_PATH" && npm start
                else
                    echo -e "${RED}Error installing modules. Returning to the menu...${NC}"
                    pos_clone_menu "$AMBIENTE_PATH"
                fi
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Invalid option.${NC}"
                iniciar_bot "$AMBIENTE_PATH"
                ;;
        esac
    fi
}



# ###########################################
# Function to stop the bot
# - Purpose: Stops the active bot session by terminating its process.
# - Edit: Only modify the echo texts if necessary to fit your project.
# - Do not edit: The logic for stopping the session and updating the status must remain unchanged.
# ###########################################
parar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "STOP THE BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        pkill -f "$COMANDO" 2>/dev/null
        clear
        atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Bot successfully stopped.${NC}"
        echo -e "${YELLOW}Restart the server after stopping to apply changes.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}No active session found to stop.${NC}"
    fi
    menu_principal
}

# ###########################################
# Function to restart the bot
# - Purpose: Restarts the bot by stopping the current session and starting a new one.
# - Edit: Only modify the echo texts if necessary to fit your project.
# - Do not edit: The logic for stopping, restarting, and updating the status must remain unchanged.
# ###########################################
reiniciar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "RESTART THE BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        pkill -f "$COMANDO" 2>/dev/null
        cd "$AMBIENTE_PATH" && nohup $COMANDO > nohup.out 2>&1 &
        clear
        atualizar_status "$AMBIENTE_PATH" "ON"
        echo -e "${GREEN}Bot successfully restarted.${NC}"
    else
        echo -e "${RED}No active session found to restart.${NC}"
    fi
    menu_principal
}

# ###########################################
# Function to view the terminal
# - Purpose: Displays the terminal output of the bot session in real-time.
# - Edit: Only modify the echo texts if necessary.
# - Do not edit: The logic for accessing and displaying the terminal output must remain unchanged.
# ###########################################
ver_terminal() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "VIEW THE TERMINAL"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/nohup.out" ]; then
        clear
        echo -e "${YELLOW}After restarting the server, you need to access the ENVIRONMENT and start the server again using option 2.${NC}"
        atualizar_status "$AMBIENTE_PATH" "OFF"
        tail -f "${AMBIENTE_PATH}/nohup.out"
    else
        echo -e "${RED}No terminal output found.${NC}"
    fi
    menu_principal
}

# ###########################################
# Function to delete the session
# - Purpose: Deletes the current bot session and terminates its process.
# - Edit: Only modify the echo texts if necessary.
# - Do not edit: The logic for deleting the session file and stopping the process must remain unchanged.
# ###########################################
deletar_sessao() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "DELETE SESSION"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        pkill -f "$COMANDO" 2>/dev/null
        rm -f "${AMBIENTE_PATH}/.session"
        clear
        atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Session successfully deleted. Please restart your server to apply changes.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}No active session found to delete.${NC}"
    fi
    menu_principal
}

# ###########################################
# Function to manage the environment
# - Purpose: Provides a menu to manage a specific environment, allowing the user to perform various actions.
# - Edit: You can modify the echo texts to fit your project's style or requirements.
# - Do not edit: The logic for handling menu options and calling respective functions must remain unchanged.
# ###########################################
gerenciar_ambiente() {
    AMBIENTE_PATH="${BASE_DIR}/ambiente$1"
    echo -e "${CYAN}======================================${NC}"
    anima_texto "MANAGING ENVIRONMENT $1"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - CHOOSE PRE-CONFIGURED BOT FROM VORTEXUS${NC}"
    echo -e "${YELLOW}2 - START THE BOT${NC}"
    echo -e "${YELLOW}3 - STOP THE BOT${NC}"
    echo -e "${YELLOW}4 - RESTART THE BOT${NC}"
    echo -e "${YELLOW}5 - VIEW THE TERMINAL${NC}"
    echo -e "${YELLOW}6 - DELETE SESSION${NC}"
    echo -e "${YELLOW}7 - REMOVE CURRENT BOT${NC}"
    echo -e "${YELLOW}8 - CLONE REPOSITORY${NC}"
    echo -e "${RED}0 - BACK${NC}"
    read -p "> " OPCAO

    case $OPCAO in
        1) escolher_bot_pronto "$AMBIENTE_PATH" ;;  # Choose a pre-configured bot
        2) iniciar_bot "$AMBIENTE_PATH" ;;          # Start the bot
        3) parar_bot "$AMBIENTE_PATH" ;;            # Stop the bot
        4) reiniciar_bot "$AMBIENTE_PATH" ;;        # Restart the bot
        5) ver_terminal "$AMBIENTE_PATH" ;;         # View the bot's terminal
        6) deletar_sessao "$AMBIENTE_PATH" ;;       # Delete the bot's session
        7) remover_bot "$AMBIENTE_PATH" ;;          # Remove the current bot
        8) clonar_repositorio "$AMBIENTE_PATH" ;;   # Clone a repository
        0) menu_principal ;;                        # Return to the main menu
        *) 
            echo -e "${RED}Invalid option.${NC}"
            gerenciar_ambiente "$1" 
            ;;
    esac
}

# Execução principal
exibir_termos
criar_pastas
verificar_sessoes
menu_principal
#verificar_whitelist
