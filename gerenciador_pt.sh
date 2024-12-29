#!/bin/bash

# === CORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # Sem cor

# === CONFIGURAÇÕES ===
# Configuração da API esperada. Esta é a chave utilizada para validar a conexão com o gerenciador principal.
API_ESPERADA="VORTEXUSCLOUD"

# === FUNÇÃO PARA VALIDAR A API ===
# Esta função verifica se a API fornecida pelo gerenciador principal corresponde à chave esperada.
# Se não corresponder, o script exibe uma mensagem de erro e encerra.
# O usuário não deve alterar esta função, a menos que entenda o funcionamento do sistema de validação.
validar_api() {
    API_RECEBIDA=$1
    if [ "$API_RECEBIDA" != "$API_ESPERADA" ]; then
        echo -e "${RED}API NÃO CONSEGUE SE CONECTAR AO ARQUIVO GERENCIADOR.SH.${NC}"
        echo -e "${YELLOW}POR FAVOR, FORNEÇA O ARQUIVO DE CONFIGURAÇÃO PARA CONSEGUIR EXECUTAR ESTE ARQUIVO.${NC}"
        echo -e "${YELLOW}CASO NÃO SAIBA, ENTRE EM CONTATO COM NOSSO SUPORTE:${NC}"
        echo -e "${CYAN}HTTPS://VORTEXCLOUD.COM.BR${NC}"
        exit 1
    fi
}

# === INICIALIZAÇÃO DO GERENCIADOR ===
# Valida a API fornecida e, se correta, inicia os sistemas. O usuário pode adicionar
# comandos personalizados após a validação, se necessário.
echo -e "${CYAN}==============================================${NC}"
echo -e "${YELLOW}VALIDANDO API...${NC}"
validar_api "$1"
echo -e "${GREEN}A API CONECTOU-SE COM SUCESSO! SISTEMAS VALIDADOS.${NC}"
echo -e "${CYAN}==============================================${NC}"

# === ABAIXO COMECA A EXECUTAR O SCRIPT MAS PRIMEIRO VERIFICA OS HOSTNAMES E IPS ===


# ###########################################
# Configurações da whitelist
# - Propósito: Define os hostnames e IPs autorizados para o sistema.
# - Editar: 
#   * Você pode adicionar ou remover hostnames em `WHITELIST_HOSTNAMES`.
#   * Pode incluir ou excluir IPs em `WHITELIST_IPS`.
# - Não editar: A estrutura da lista e a lógica de validação devem permanecer intactas.
# ###########################################
WHITELIST_HOSTNAMES=("app.vexufy.com")
WHITELIST_IPS=("199.85.209.85" "199.85.209.109")
VALIDATED=false  # Flag para indicar se o ambiente foi validado com sucesso.

# ###########################################
# Função para obter IPs privados e públicos
# - Propósito: Coleta os IPs privados e públicos do servidor em execução.
# - Editar: Não é necessário editar esta função, pois ela é independente de configurações externas.
# ###########################################
obter_ips() {
    # Obtém o IP privado
    IP_PRIVADO=$(hostname -I | awk '{print $1}')
    
    # Obtém o IP público usando diferentes serviços online
    IP_PUBLICO=""
    SERVICOS=("ifconfig.me" "api64.ipify.org" "ipecho.net/plain")
    
    for SERVICO in "${SERVICOS[@]}"; do
        IP_PUBLICO=$(curl -s --max-time 5 "http://${SERVICO}")
        if [[ $IP_PUBLICO =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        fi
    done

    # Caso não consiga obter o IP público
    if [ -z "$IP_PUBLICO" ]; then
        IP_PUBLICO="Não foi possível obter o IP público"
    fi

    echo "$IP_PRIVADO" "$IP_PUBLICO"
}

# ###########################################
# Função para validar o ambiente
# - Propósito: Confirma se o ambiente atual está autorizado a executar o sistema.
# - Editar:
#   * Você pode ajustar as mensagens exibidas no terminal (os comandos `echo`).
# - Não editar: Não altere a lógica de verificação ou o comportamento do loop.
# ###########################################
validar_ambiente() {
    # Exibe uma mensagem de validação inicial
    echo -e "\033[1;36m======================================"
    echo -e "       VALIDANDO AMBIENTE..."
    echo -e "======================================\033[0m"
    sleep 2  # Simula o tempo de validação

    # Coleta os IPs público e privado
    read -r IP_PRIVADO IP_PUBLICO <<<"$(obter_ips)"

    # Resolve os IPs dos hostnames na whitelist
    for HOSTNAME in "${WHITELIST_HOSTNAMES[@]}"; do
        RESOLVIDOS=$(getent ahosts "$HOSTNAME" | awk '{print $1}' | sort -u)
        WHITELIST_IPS+=($RESOLVIDOS)
    done

    # Mostra as informações coletadas
    echo -e "\033[1;33mHostname atual: $(hostname)"
    echo -e "IP privado atual: $IP_PRIVADO"
    echo -e "IP público atual: $IP_PUBLICO"
    echo -e "======================================\033[0m"
    sleep 3  # Dá tempo para o usuário ver as informações

    # Verifica se o IP privado ou público está autorizado
    if [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PRIVADO} " ]] || [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PUBLICO} " ]]; then
        echo -e "\033[1;32m✔ Ambiente validado com sucesso! Continuando...\033[0m"
        VALIDATED=true
        return 0
    fi

    # Loop para ambientes não autorizados
    while true; do
        clear
        echo -e "\033[1;31m======================================"
        echo -e "❌ ERRO: AMBIENTE NÃO AUTORIZADO"
        echo -e "--------------------------------------"
        echo -e "⚠️  Este sistema não é licenciado para uso externo."
        echo -e "⚠️  É estritamente proibido utilizar este sistema fora dos servidores autorizados."
        echo -e "--------------------------------------"
        echo -e "➡️  Hostname atual: $(hostname)"
        echo -e "➡️  IP privado atual: $IP_PRIVADO"
        echo -e "➡️  IP público atual: $IP_PUBLICO"
        echo -e "--------------------------------------"
        echo -e "✅ Servidores autorizados: ${WHITELIST_HOSTNAMES[*]}"
        echo -e "✅ IPs autorizados: ${WHITELIST_IPS[*]}"
        echo -e "--------------------------------------"
        echo -e "💡 Para adquirir uma licença ou contratar nossos serviços de hospedagem:"
        echo -e "   🌐 Acesse clicando aqui: \033[1;34mhttps://vortexuscloud.com.br\033[0m"
        echo -e "======================================\033[0m"
        sleep 10
    done
}

# ###########################################
# Função de validação secundária
# - Propósito: Realiza uma validação adicional para confirmar o ambiente autorizado.
# - Editar: Não é necessário editar esta função.
# ###########################################
validar_secundario() {
    echo -e "\033[1;36mRevalidando ambiente...\033[0m"
    sleep 2
    validar_ambiente
}

# ###########################################
# Verificação inicial da whitelist
# - Propósito: Realiza a validação antes de iniciar qualquer operação.
# - Editar: Não é necessário editar esta função.
# ###########################################
if [ "$VALIDATED" = false ]; then
    validar_ambiente
fi

# ###########################################
# Início do script principal
# - Propósito: Exibe uma mensagem inicial após a validação bem-sucedida.
# - Editar: Pode ajustar o texto exibido pelo comando `echo`.
# ###########################################
echo -e "\033[1;36mBem-vindo ao sistema autorizado! Preparando validações subsequentes...\033[0m"
sleep 5
validar_secundario

echo -e "\033[1;32m======================================"
echo -e "    Sistema autorizado e operacional!"
echo -e "======================================\033[0m"

# ###########################################
# Configurações principais
# - Propósito: Define o diretório base e outras configurações essenciais do sistema.
# - Editar:
#   * `BASE_DIR`: Modifique para alterar o diretório base onde os ambientes serão criados.
#   * `NUM_AMBIENTES`: Ajuste o número de ambientes que deseja criar.
#   * `TERMS_FILE`: Altere o caminho do arquivo de termos, se necessário.
# - Não editar: Não altere a lógica de uso das variáveis, apenas seus valores.
# ###########################################
BASE_DIR="/home/container" # Diretório base onde os ambientes serão criados.
NUM_AMBIENTES=8           # Número de ambientes que serão configurados.
TERMS_FILE="${BASE_DIR}/termos_accepted.txt" # Caminho do arquivo que indica a aceitação dos termos de serviço.

# ###########################################
# Cores ANSI
# - Propósito: Define cores para saída no terminal.
# - Editar: Não é necessário editar a configuração das cores.
# ###########################################
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor

# ###########################################
# Função de animação
# - Propósito: Exibe um texto animado no terminal.
# - Editar: Você pode alterar o texto passado para a função quando utilizá-la.
# - Não editar: Não é necessário alterar a lógica da animação.
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
# Função para exibir o outdoor 3D com texto estático
# - Propósito: Exibe um cabeçalho em formato de arte ASCII.
# - Editar:
#   * Você pode personalizar o texto ASCII e as informações exibidas abaixo.
#   * Altere os links ou mensagens para adequar ao seu projeto.
# - Não editar: A lógica para centralizar o texto e exibir a animação.
# ###########################################
exibir_outdoor_3D() {
    clear
    local width=$(tput cols)  # Largura do terminal
    local height=$(tput lines)  # Altura do terminal
    local start_line=$(( height / 3 ))
    local start_col=$(( (width - 60) / 2 ))  # Centraliza o texto

    # Arte 3D do texto principal
    local outdoor_text=(
        " _   _  ___________ _____ _______   ___   _ _____ "
        "| | | ||  _  | ___ \\_   _|  ___\\ \\ / / | | /  ___|"
        "| | | || | | | |_/ / | | | |__  \\ V /| | | \\ --. "
        "| | | || | | |    /  | | |  __| /   \\| | | |--. \\"
        "\\ \\_/ /\\ \\_/ / |\\ \\  | | | |___/ /^\\ \\ |_| /\\__/ /"
        " \\___/  \\___/\\_| \\_| \\_/ \\____/\\/   \\/\\___/\\____/ "
    )

    # Exibe o texto 3D centralizado
    for i in "${!outdoor_text[@]}"; do
        tput cup $((start_line + i)) $start_col
        echo -e "${CYAN}${outdoor_text[i]}${NC}"
    done

    # Exibe "Created by Mauro Gashfix" diretamente abaixo do texto 3D
    local footer="Created by Mauro Gashfix"
    tput cup $((start_line + ${#outdoor_text[@]} + 1)) $(( (width - ${#footer}) / 2 ))
    echo -e "${YELLOW}${footer}${NC}"

    # Exibe os links diretamente abaixo do footer
    local links="vortexuscloud.com.br & vortexuscloud.com"
    tput cup $((start_line + ${#outdoor_text[@]} + 2)) $(( (width - ${#links}) / 2 ))
    echo -e "${GREEN}${links}${NC}"

    # Exibe a barra de inicialização diretamente abaixo dos links
    local progress_bar="Inicializando..."
    tput cup $((start_line + ${#outdoor_text[@]} + 4)) $(( (width - ${#progress_bar} - 20) / 2 ))
    echo -ne "${CYAN}${progress_bar}${NC}"
    for i in $(seq 1 20); do
        echo -ne "${GREEN}#${NC}"
        sleep 0.1
    done
    echo ""
}

# ###########################################
# Função para exibir os termos de serviço
# - Propósito: Solicita que o usuário aceite os termos antes de continuar.
# - Editar:
#   * Personalize as mensagens de termos de serviço exibidas ao usuário.
#   * Altere o texto "ACEITA OS TERMOS?" para refletir as políticas do seu projeto.
# - Não editar: A lógica de verificação e armazenamento do aceite.
# ###########################################
exibir_termos() {
    exibir_outdoor_3D
    sleep 1
    echo -e "${BLUE}Este sistema é permitido apenas na plataforma Vortexus Cloud.${NC}"
    echo -e "${CYAN}======================================${NC}"

    if [ ! -f "$TERMS_FILE" ]; then
        while true; do
            echo -e "${YELLOW}VOCÊ ACEITA OS TERMOS DE SERVIÇO? (SIM/NÃO)${NC}"
            read -p "> " ACEITE
            if [ "$ACEITE" = "sim" ]; then
                echo -e "${GREEN}Termos aceitos em $(date).${NC}" > "$TERMS_FILE"
                echo -e "${CYAN}======================================${NC}"
                echo -e "${GREEN}TERMOS ACEITOS. PROSSEGUINDO...${NC}"
                break
            elif [ "$ACEITE" = "não" ]; then
                echo -e "${RED}VOCÊ DEVE ACEITAR OS TERMOS PARA CONTINUAR.${NC}"
            else
                echo -e "${RED}OPÇÃO INVÁLIDA. DIGITE 'SIM' OU 'NÃO'.${NC}"
            fi
        done
    else
        echo -e "${GREEN}TERMOS JÁ ACEITOS ANTERIORMENTE. PROSSEGUINDO...${NC}"
    fi
}

# ###########################################
# Função para criar pastas dos ambientes
# - Propósito: Cria as pastas necessárias para cada ambiente configurado.
# - Editar:
#   * Altere o número de ambientes em `NUM_AMBIENTES` se desejar criar mais ou menos pastas.
# - Não editar: A lógica de criação de pastas.
# ###########################################
criar_pastas() {
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ ! -d "$AMBIENTE_PATH" ]; then
            mkdir -p "$AMBIENTE_PATH"
            echo -e "${GREEN}PASTA DO AMBIENTE ${i} CRIADA.${NC}"
        fi
    done
}

# ###########################################
# Atualizar status do ambiente
# - Propósito: Atualiza o status de um ambiente específico.
# - Editar: Não é necessário editar esta função.
# ###########################################
atualizar_status() {
    AMBIENTE_PATH=$1
    NOVO_STATUS=$2
    echo "$NOVO_STATUS" > "${AMBIENTE_PATH}/status"
    echo -e "${CYAN}Status do ambiente atualizado para: ${GREEN}${NOVO_STATUS}${NC}"
}

# ###########################################
# Recuperar status do ambiente
# - Propósito: Obtém o status atual de um ambiente específico.
# - Editar: Não é necessário editar esta função.
# ###########################################
recuperar_status() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/status" ]; then
        cat "${AMBIENTE_PATH}/status"
    else
        echo "OFF"
    fi
}

# ###########################################
# Função para verificar e reiniciar sessões em background
# - Propósito: Verifica se há sessões em execução nos ambientes e reinicia, se necessário.
# - Editar: Não é necessário editar essa função. Somente ajuste as mensagens de texto para refletir o seu projeto.
# - Não editar: A lógica de verificação de sessões e reinício.
# ###########################################
verificar_sessoes() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "VERIFICANDO SESSOES EM BACKGROUND..."
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ -f "${AMBIENTE_PATH}/.session" ]; then
            STATUS=$(recuperar_status "$AMBIENTE_PATH")
            if [ "$STATUS" = "ON" ]; then
                COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                
                if [ -n "$COMANDO" ]; then
                    echo -e "${YELLOW}Executando sessão em background para o ambiente ${i}...${NC}"
                    pkill -f "$COMANDO" 2>/dev/null
                    cd "$AMBIENTE_PATH" || continue
                    nohup $COMANDO > nohup.out 2>&1 &
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}SESSÃO EM BACKGROUND ATIVA PARA O AMBIENTE ${i}.${NC}"
                    else
                        echo -e "${RED}Erro ao tentar ativar a sessão no ambiente ${i}.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Comando vazio encontrado no arquivo .session do ambiente ${i}.${NC}"
                fi
            else
                echo -e "${RED}O ambiente ${i} está com status OFF. Ignorando...${NC}"
            fi
        else
            echo -e "${RED}Nenhum arquivo .session encontrado no ambiente ${i}.${NC}"
        fi
    done
    echo -e "${CYAN}======================================${NC}"
}

# ###########################################
# Função para exibir o menu principal
# - Propósito: Gerencia a navegação entre os ambientes configurados.
# - Editar: Ajuste as mensagens e opções de texto conforme necessário.
# - Não editar: A lógica de navegação e escolha de ambiente.
# ###########################################
menu_principal() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       GERENCIAMENTO DE AMBIENTES"
    echo -e "${CYAN}======================================${NC}"
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        echo -e "${YELLOW}AMBIENTE ${i}:${NC} ${GREEN}STATUS - $STATUS${NC}"
    done
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}ESCOLHA UM AMBIENTE PARA GERENCIAR (1-${NUM_AMBIENTES}):${NC}"
    echo -e "${RED}0 - SAIR${NC}"
    read -p "> " AMBIENTE_ESCOLHIDO

    if [ "$AMBIENTE_ESCOLHIDO" -ge 1 ] && [ "$AMBIENTE_ESCOLHIDO" -le "$NUM_AMBIENTES" ]; then
        gerenciar_ambiente "$AMBIENTE_ESCOLHIDO"
    elif [ "$AMBIENTE_ESCOLHIDO" = "0" ]; then
        anima_texto "SAINDO..."
        exit 0
    else
        echo -e "${RED}ESCOLHA INVÁLIDA. TENTE NOVAMENTE.${NC}"
        menu_principal
    fi
}

# ###########################################
# Função para escolher um bot pronto da Vortexus
# - Propósito: Permite ao usuário selecionar uma lista de bots disponíveis.
# - Editar: Adicione ou remova opções de idiomas disponíveis.
# - Não editar: A lógica de escolha e navegação de menus.
# ###########################################
escolher_bot_pronto() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       ESCOLHER BOT PRONTO"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - BOTS EM PORTUGUÊS${NC}"
    echo -e "${YELLOW}2 - BOTS EM ESPANHOL${NC}"
    echo -e "${RED}0 - VOLTAR${NC}"
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
            echo -e "${RED}Opção inválida.${NC}"
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Função para listar bots disponíveis
# - Propósito: Lista os bots disponíveis de acordo com o idioma selecionado.
# - Editar:
#   * Para adicionar novos bots, insira uma nova linha na estrutura correspondente ao idioma:
#     Exemplo para português:
#       "NOME DO BOT - LINK DO REPOSITÓRIO"
#   * Para adicionar novos idiomas, copie a estrutura `elif` e substitua o idioma e os bots.
# - Não editar: A lógica de listagem e seleção de bots.
# ###########################################
listar_bots() {
    AMBIENTE_PATH=$1
    LINGUA=$2
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       BOTS DISPONÍVEIS - ${LINGUA^^}"
    echo -e "${CYAN}======================================${NC}"

    # Estrutura de bots disponíveis
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
            "YAEMORI BOT - https://github.com/Dev-Diego/YaemoriBot-MD"
            "THEMYSTIC BOT - https://github.com/BrunoSobrino/TheMystic-Bot-MD.git"
        )
    fi

    # Passo a passo para adicionar bots:
    # 1. Para cada idioma, localize o bloco `if [ "$LINGUA" = "<idioma>" ];`.
    # 2. Adicione uma nova linha no formato:
    #    "NOME DO BOT - LINK DO REPOSITÓRIO"
    # 3. Para adicionar um novo idioma:
    #    a. Copie um dos blocos existentes (como o `elif [ "$LINGUA" = "espanhol" ];`).
    #    b. Substitua `<idioma>` pelo novo idioma.
    #    c. Adicione os bots correspondentes.
    # 4. Certifique-se de manter o formato correto para que os bots sejam exibidos corretamente.

    for i in "${!BOTS[@]}"; do
        echo -e "${GREEN}$((i+1)) - ${BOTS[$i]%% -*}${NC}"
    done
    echo -e "${RED}0 - VOLTAR${NC}"

    read -p "> " BOT_ESCOLHIDO

    if [ "$BOT_ESCOLHIDO" -ge 1 ] && [ "$BOT_ESCOLHIDO" -le "${#BOTS[@]}" ]; then
        REPOSITORIO="${BOTS[$((BOT_ESCOLHIDO-1))]#*- }"
        verificar_instalacao_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    elif [ "$BOT_ESCOLHIDO" = "0" ]; then
        escolher_bot_pronto "$AMBIENTE_PATH"
    else
        echo -e "${RED}Opção inválida.${NC}"
        listar_bots "$AMBIENTE_PATH" "$LINGUA"
    fi
}


# ###########################################
# Função para verificar a instalação de um bot
# - Propósito: Checa se já existe um bot instalado no ambiente. Se sim, oferece a opção de substituí-lo.
# - Editar: Não é necessário editar a lógica. Somente ajuste as mensagens de texto, se necessário.
# ###########################################
verificar_instalacao_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Já existe um bot instalado neste ambiente.${NC}"
        echo -e "${YELLOW}Deseja remover o bot existente para instalar o novo? (sim/não)${NC}"
        read -p "> " RESPOSTA
        if [ "$RESPOSTA" = "sim" ]; then
            remover_bot "$AMBIENTE_PATH"
            instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
        else
            echo -e "${RED}Retornando ao menu principal...${NC}"
            menu_principal
        fi
    else
        instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    fi
}

# ###########################################
# Função para instalar um novo bot
# - Propósito: Clona o repositório do bot e verifica os módulos necessários para instalação.
# - Editar: Não é necessário editar a lógica. Apenas ajuste as mensagens, se necessário.
# ###########################################
instalar_novo_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    NOME_BOT=$(basename "$REPOSITORIO" .git)
    echo -e "${CYAN}Iniciando a instalação do bot: ${GREEN}$NOME_BOT${NC}..."
    git clone "$REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bot $NOME_BOT instalado com sucesso no ambiente $AMBIENTE_PATH!${NC}"
        verificar_node_modules "$AMBIENTE_PATH"
    else
        echo -e "${RED}Erro ao clonar o repositório do bot $NOME_BOT. Verifique a URL e tente novamente.${NC}"
    fi
}

# ###########################################
# Função para verificar e instalar módulos Node.js
# - Propósito: Certifica-se de que todos os módulos necessários estejam instalados.
# - Editar: Apenas ajuste as mensagens, se necessário.
# ###########################################
verificar_node_modules() {
    AMBIENTE_PATH=$1
    if [ ! -d "${AMBIENTE_PATH}/node_modules" ]; then
        echo -e "${YELLOW}Módulos não instalados neste bot.${NC}"
        echo -e "${YELLOW}Escolha uma opção para instalação:${NC}"
        echo -e "${GREEN}1 - npm install${NC}"
        echo -e "${GREEN}2 - yarn install${NC}"
        echo -e "${RED}0 - Voltar${NC}"
        read -p "> " OPCAO_MODULOS
        case $OPCAO_MODULOS in
            1)
                echo -e "${CYAN}Instalando módulos com npm...${NC}"
                cd "$AMBIENTE_PATH" && npm install
                [ $? -eq 0 ] && echo -e "${GREEN}Módulos instalados com sucesso!${NC}" || echo -e "${RED}Erro ao instalar módulos com npm.${NC}"
                ;;
            2)
                echo -e "${CYAN}Instalando módulos com yarn...${NC}"
                cd "$AMBIENTE_PATH" && yarn install
                [ $? -eq 0 ] && echo -e "${GREEN}Módulos instalados com sucesso!${NC}" || echo -e "${RED}Erro ao instalar módulos com yarn.${NC}"
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Opção inválida.${NC}"
                verificar_node_modules "$AMBIENTE_PATH"
                ;;
        esac
    else
        echo -e "${GREEN}Todos os módulos necessários já estão instalados.${NC}"
    fi
    pos_clone_menu "$AMBIENTE_PATH"
}

# ###########################################
# Função para remover bot atual
# - Propósito: Remove todos os arquivos do ambiente para liberar espaço para outro bot.
# - Editar: Apenas ajuste as mensagens, se necessário.
# ###########################################
remover_bot() {
    AMBIENTE_PATH=$1

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Bot detectado neste ambiente.${NC}"
        echo -e "${RED}Deseja realmente remover o bot atual? (sim/não)${NC}"
        read -p "> " CONFIRMAR
        if [ "$CONFIRMAR" = "sim" ]; then
            find "$AMBIENTE_PATH" -mindepth 1 -exec rm -rf {} + 2>/dev/null
            [ -z "$(ls -A "$AMBIENTE_PATH")" ] && echo -e "${GREEN}Bot removido com sucesso.${NC}" || echo -e "${RED}Erro ao remover o bot.${NC}"
        else
            echo -e "${RED}Remoção cancelada.${NC}"
        fi
    else
        echo -e "${RED}Nenhum bot encontrado neste ambiente.${NC}"
    fi
    menu_principal
}

# ###########################################
# Função para clonar repositório
# - Propósito: Permite clonar repositórios públicos e privados no ambiente.
# - Editar:
#   * Ajuste as mensagens, se necessário.
#   * Para tokens de acesso privado, mantenha as instruções para o usuário.
# ###########################################
clonar_repositorio() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       CLONAR REPOSITÓRIO"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Clonar repositório público${NC}"
    echo -e "${YELLOW}2 - Clonar repositório privado${NC}"
    echo -e "${RED}0 - Voltar${NC}"
    read -p "> " OPCAO_CLONAR

    case $OPCAO_CLONAR in
        1)
            echo -e "${CYAN}Forneça a URL do repositório público:${NC}"
            read -p "> " URL_REPOSITORIO
            if [[ $URL_REPOSITORIO != https://github.com/* ]]; then
                echo -e "${RED}URL inválida!${NC}"
                clonar_repositorio "$AMBIENTE_PATH"
                return
            fi
            echo -e "${CYAN}Clonando repositório público...${NC}"
            git clone "$URL_REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}Repositório clonado com sucesso!${NC}" || echo -e "${RED}Erro ao clonar o repositório.${NC}"
            ;;
        2)
            echo -e "${CYAN}Forneça a URL do repositório privado:${NC}"
            read -p "> " URL_REPOSITORIO
            echo -e "${CYAN}Usuário do GitHub:${NC}"
            read -p "> " USERNAME
            echo -e "${CYAN}Forneça o token de acesso:${NC}"
            read -s -p "> " TOKEN
            echo
            GIT_URL="https://${USERNAME}:${TOKEN}@$(echo $URL_REPOSITORIO | cut -d/ -f3-)"
            echo -e "${CYAN}Clonando repositório privado...${NC}"
            git clone "$GIT_URL" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}Repositório privado clonado com sucesso!${NC}" || echo -e "${RED}Erro ao clonar o repositório privado.${NC}"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Opção inválida.${NC}"
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Função para o menu pós-clone
# - Propósito: Permite que o usuário escolha o que fazer após clonar um repositório.
# - Editar: 
#   * Ajustar mensagens, se necessário.
#   * Não é necessário alterar a lógica principal.
# ###########################################
pos_clone_menu() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "O QUE VOCÊ DESEJA FAZER AGORA?"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Executar o bot${NC}"
    echo -e "${YELLOW}2 - Instalar módulos${NC}"
    echo -e "${RED}0 - Voltar para o menu principal${NC}"
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
            echo -e "${RED}Opção inválida.${NC}"
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Função para instalar módulos
# - Propósito: Garante que as dependências necessárias para o bot sejam instaladas.
# - Editar:
#   * Ajustar mensagens, se necessário.
#   * A lógica principal não requer alterações.
# ###########################################
instalar_modulos() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "INSTALAR MÓDULOS"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Instalar com npm install${NC}"
    echo -e "${YELLOW}2 - Instalar com yarn install${NC}"
    echo -e "${RED}0 - Voltar para o menu principal${NC}"
    read -p "> " OPCAO_MODULOS

    case $OPCAO_MODULOS in
        1)
            echo -e "${CYAN}Instalando módulos com npm...${NC}"
            cd "$AMBIENTE_PATH" && npm install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Módulos instalados com sucesso!${NC}"
            else
                echo -e "${RED}Erro ao instalar módulos com npm.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        2)
            echo -e "${CYAN}Instalando módulos com yarn...${NC}"
            cd "$AMBIENTE_PATH" && yarn install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Módulos instalados com sucesso!${NC}"
            else
                echo -e "${RED}Erro ao instalar módulos com yarn.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Opção inválida.${NC}"
            instalar_modulos "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Função para iniciar o bot
# - Propósito: Inicia o bot com base nas configurações do ambiente.
# - Editar:
#   * Ajustar mensagens, se necessário.
#   * Mantenha a lógica principal inalterada para evitar conflitos.
# ###########################################
iniciar_bot() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        if [ "$STATUS" = "OFF" ]; then
            echo -e "${YELLOW}Sessão existente com status OFF.${NC}"
            echo -e "${YELLOW}1 - Reiniciar o bot${NC}"
            echo -e "${RED}0 - Voltar${NC}"
            read -p "> " OPCAO_EXISTENTE
            case $OPCAO_EXISTENTE in
                1)
                    COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                    nohup sh -c "cd $AMBIENTE_PATH && $COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &
                    clear
                    atualizar_status "$AMBIENTE_PATH" "ON"
                    echo -e "${GREEN}Bot reiniciado com sucesso!${NC}"
                    menu_principal
                    ;;
                0)
                    menu_principal
                    ;;
                *)
                    echo -e "${RED}Opção inválida.${NC}"
                    iniciar_bot "$AMBIENTE_PATH"
                    ;;
            esac
        elif [ "$STATUS" = "ON" ]; then
            echo -e "${RED}Já existe uma sessão ativa neste ambiente.${NC}"
            echo -e "${RED}Por favor, finalize a sessão atual antes de iniciar outra.${NC}"
            echo -e "${YELLOW}0 - Voltar${NC}"
            read -p "> " OPCAO
            [ "$OPCAO" = "0" ] && menu_principal
        fi
    else
        echo -e "${CYAN}Escolha como deseja iniciar o bot:${NC}"
        echo -e "${YELLOW}1 - npm start${NC}"
        echo -e "${YELLOW}2 - Especificar arquivo (ex: index.js ou start.sh)${NC}"
        echo -e "${YELLOW}3 - Instalar módulos e executar o bot${NC}"
        echo -e "${RED}0 - Voltar${NC}"
        read -p "> " INICIAR_OPCAO

        case $INICIAR_OPCAO in
            1)
                echo "npm start" > "${AMBIENTE_PATH}/.session"
                clear
                echo -e "${YELLOW}Reinice o servidor assim que terminar para dar efeito${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    cd "$AMBIENTE_PATH" && npm start
                    echo -e "${YELLOW}1 - Reiniciar o bot${NC}"
                    echo -e "${YELLOW}2 - Salvar e voltar ao menu principal${NC}"
                    echo -e "${RED}0 - Voltar${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Reiniciando o processo...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Salvando e voltando ao menu principal...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Opção inválida.${NC}"
                            ;;
                    esac
                done
                ;;
            2)
                echo -e "${YELLOW}Digite o nome do arquivo para executar:${NC}"
                read ARQUIVO
                if [[ $ARQUIVO == *.sh ]]; then
                    echo "sh $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                else
                    echo "node $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                fi
                clear
                echo -e "${YELLOW}Reinice o servidor assim que terminar para dar efeito${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    if [[ $ARQUIVO == *.sh ]]; then
                        cd "$AMBIENTE_PATH" && sh "$ARQUIVO"
                    else
                        cd "$AMBIENTE_PATH" && node "$ARQUIVO"
                    fi
                    echo -e "${YELLOW}1 - Reiniciar o bot${NC}"
                    echo -e "${YELLOW}2 - Salvar e voltar ao menu principal${NC}"
                    echo -e "${RED}0 - Voltar${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Reiniciando o processo...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Salvando e voltando ao menu principal...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Opção inválida.${NC}"
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
                    echo -e "${RED}Erro ao instalar módulos. Retornando ao menu...${NC}"
                    pos_clone_menu "$AMBIENTE_PATH"
                fi
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Opção inválida.${NC}"
                iniciar_bot "$AMBIENTE_PATH"
                ;;
        esac
    fi
}


# ###########################################
# Função para parar o bot
# - Propósito: Finaliza o processo do bot em execução em segundo plano.
# - Editar:
#   * Ajustar mensagens exibidas, se necessário.
#   * A lógica de finalização do processo e atualização do status não deve ser alterada.
# ###########################################
parar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "PARAR O BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        
        # Finaliza o processo do bot
        pkill -f "$COMANDO" 2>/dev/null
        clear
        atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Bot parado com sucesso.${NC}"
        echo -e "${YELLOW}Reinice o servidor assim que terminar para dar efeito.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}Nenhuma sessão ativa encontrada para parar.${NC}"
    fi
    menu_principal
}

# ###########################################
# Função para reiniciar o bot
# - Propósito: Reinicia o processo do bot com base nas configurações do ambiente.
# - Editar:
#   * Mensagens exibidas, se necessário.
#   * A lógica principal deve permanecer inalterada para evitar conflitos.
# ###########################################
reiniciar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "REINICIAR O BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        
        # Finaliza o processo antigo e inicia um novo
        pkill -f "$COMANDO" 2>/dev/null
        cd "$AMBIENTE_PATH" && nohup $COMANDO > nohup.out 2>&1 &
        clear
        atualizar_status "$AMBIENTE_PATH" "ON"
        echo -e "${GREEN}Bot reiniciado com sucesso.${NC}"
    else
        echo -e "${RED}Nenhuma sessão ativa encontrada para reiniciar.${NC}"
    fi
    menu_principal
}

# ###########################################
# Função para visualizar o terminal
# - Propósito: Permite visualizar os logs gerados pelo bot.
# - Editar:
#   * Ajustar mensagens exibidas.
#   * Não alterar a lógica para evitar erros ao acessar os logs.
# ###########################################
ver_terminal() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "VISUALIZAR O TERMINAL"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/nohup.out" ]; then
        clear
        echo -e "${YELLOW}Quando reiniciar o servidor você precisa acessar o AMBIENTE e iniciar o servidor novamente na opção 2.${NC}"
        atualizar_status "$AMBIENTE_PATH" "OFF"
        tail -f "${AMBIENTE_PATH}/nohup.out"
    else
        echo -e "${RED}Nenhuma saída encontrada para o terminal.${NC}"
    fi
    menu_principal
}

# ###########################################
# Função para deletar a sessão
# - Propósito: Remove o arquivo de sessão associado ao bot e finaliza o processo em execução.
# - Editar:
#   * Ajustar mensagens exibidas, se necessário.
#   * A lógica de exclusão e finalização do processo deve ser mantida.
# ###########################################
deletar_sessao() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "DELETAR SESSÃO"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        
        # Finaliza o processo e remove o arquivo de sessão
        pkill -f "$COMANDO" 2>/dev/null
        rm -f "${AMBIENTE_PATH}/.session"
        clear
        atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Sessão deletada com sucesso. Por favor, reinicie seu servidor para dar efeito.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}Nenhuma sessão ativa encontrada para deletar.${NC}"
    fi
    menu_principal
}

# ###########################################
# Função para gerenciar ambiente
# - Propósito: Fornece um menu interativo para gerenciar um ambiente específico.
# - Editar:
#   * Mensagens exibidas para o usuário podem ser personalizadas.
#   * Não altere as chamadas de funções ou lógica principal do menu.
# ###########################################
gerenciar_ambiente() {
    # Define o caminho do ambiente com base no índice
    AMBIENTE_PATH="${BASE_DIR}/ambiente$1"

    # Cabeçalho do menu
    echo -e "${CYAN}======================================${NC}"
    anima_texto "GERENCIANDO AMBIENTE $1"
    echo -e "${CYAN}======================================${NC}"

    # Opções do menu
    echo -e "${YELLOW}1 - ESCOLHER BOT PRONTO DA VORTEXUS${NC}"
    echo -e "${YELLOW}2 - INICIAR O BOT${NC}"
    echo -e "${YELLOW}3 - PARAR O BOT${NC}"
    echo -e "${YELLOW}4 - REINICIAR O BOT${NC}"
    echo -e "${YELLOW}5 - VISUALIZAR O TERMINAL${NC}"
    echo -e "${YELLOW}6 - DELETAR SESSÃO${NC}"
    echo -e "${YELLOW}7 - REMOVER BOT ATUAL${NC}"
    echo -e "${YELLOW}8 - CLONAR REPOSITÓRIO${NC}"
    echo -e "${RED}0 - VOLTAR${NC}"

    # Recebe a opção do usuário
    read -p "> " OPCAO

    # Switch para redirecionar para a função correspondente
    case $OPCAO in
        1) 
            # Escolher bot pronto
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
        2) 
            # Iniciar o bot
            iniciar_bot "$AMBIENTE_PATH"
            ;;
        3) 
            # Parar o bot
            parar_bot "$AMBIENTE_PATH"
            ;;
        4) 
            # Reiniciar o bot
            reiniciar_bot "$AMBIENTE_PATH"
            ;;
        5) 
            # Visualizar o terminal
            ver_terminal "$AMBIENTE_PATH"
            ;;
        6) 
            # Deletar sessão
            deletar_sessao "$AMBIENTE_PATH"
            ;;
        7) 
            # Remover bot atual
            remover_bot "$AMBIENTE_PATH"
            ;;
        8) 
            # Clonar repositório
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
        0) 
            # Voltar ao menu principal
            menu_principal
            ;;
        *) 
            # Opção inválida
            echo -e "${RED}Opção inválida.${NC}"
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