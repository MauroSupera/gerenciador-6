#!/bin/bash

# === COLORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # Sin color

# === CONFIGURACIÓN ===
# Configuración de la API esperada. Esta es la clave utilizada para validar la conexión con el gestor principal.
API_ESPERADA="VORTEXUSCLOUD"

# === FUNCIÓN PARA VALIDAR LA API ===
# Esta función verifica si la API proporcionada por el gestor principal corresponde con la clave esperada.
# Si no coincide, el script muestra un mensaje de error y se cierra.
# El usuario no debe modificar esta función a menos que comprenda cómo funciona la validación.
validar_api() {
    API_RECIBIDA=$1
    if [ "$API_RECIBIDA" != "$API_ESPERADA" ]; then
        echo -e "${RED}LA API NO PUEDE CONECTARSE AL ARCHIVO GERENCIADOR.SH.${NC}"
        echo -e "${YELLOW}POR FAVOR, PROPORCIONE EL ARCHIVO DE CONFIGURACIÓN PARA EJECUTAR ESTE ARCHIVO.${NC}"
        echo -e "${YELLOW}SI NO SABE, CONTACTE CON NUESTRO SOPORTE:${NC}"
        echo -e "${CYAN}HTTPS://VORTEXCLOUD.COM.BR${NC}"
        exit 1
    fi
}

# === INICIO DEL GESTOR ===
# Valida la API proporcionada y, si es correcta, inicia los sistemas. El usuario puede añadir
# comandos personalizados después de la validación, si es necesario.
echo -e "${CYAN}==============================================${NC}"
echo -e "${YELLOW}VALIDANDO API...${NC}"
validar_api "$1"
echo -e "${GREEN}¡LA API SE CONECTÓ CON ÉXITO! SISTEMAS VALIDADOS.${NC}"
echo -e "${CYAN}==============================================${NC}"

# === A CONTINUACIÓN COMIENZA A EJECUTARSE, EL SCRIPT PRIMERO VERIFICA LOS NOMBRES DE HOST Y EL IPS ===

# ###########################################
# Configuración de la whitelist
# - Propósito: Define los nombres de host e IPs autorizados para acceder al sistema.
# - Editar: Puedes añadir o modificar los valores en las listas WHITELIST_HOSTNAMES y WHITELIST_IPS según las necesidades de tu proyecto.
# - No editar: La lógica para manejar las listas y validarlas no debe ser modificada.
# ###########################################
WHITELIST_HOSTNAMES=("app.vexufy.com")
WHITELIST_IPS=("199.85.209.85" "199.85.209.109")
VALIDATED=false  # Flag para indicar si el ambiente ha sido validado

# ###########################################
# Función para obtener IPs privadas y públicas
# - Propósito: Obtiene las IPs privadas y públicas de la máquina actual.
# - Editar: Solo modificar los mensajes en los comandos echo si es necesario.
# - No editar: La lógica que obtiene las IPs debe permanecer inalterada.
# ###########################################
obter_ips() {
    # Obtener la IP privada
    IP_PRIVADO=$(hostname -I | awk '{print $1}')
    
    # Obtener la IP pública usando servicios alternativos
    IP_PUBLICO=""
    SERVICOS=("ifconfig.me" "api64.ipify.org" "ipecho.net/plain")
    
    for SERVICO in "${SERVICOS[@]}"; do
        IP_PUBLICO=$(curl -s --max-time 5 "http://${SERVICO}")
        if [[ $IP_PUBLICO =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        fi
    done

    # Verificar si se pudo obtener la IP pública
    if [ -z "$IP_PUBLICO" ]; then
        IP_PUBLICO="No fue posible obtener la IP pública"
    fi

    echo "$IP_PRIVADO" "$IP_PUBLICO"
}

# ###########################################
# Función para validar el ambiente
# - Propósito: Verifica si el ambiente actual está autorizado, comparando la IP pública/privada con la whitelist.
# - Editar: Solo los mensajes en los comandos echo si es necesario.
# - No editar: La lógica de validación no debe ser modificada.
# ###########################################
validar_ambiente() {
    # Mostrar mensaje inicial de validación
    echo -e "\033[1;36m======================================"
    echo -e "       VALIDANDO AMBIENTE..."
    echo -e "======================================\033[0m"
    sleep 2  # Simular proceso de validación

    # Obtener IPs públicas y privadas
    read -r IP_PRIVADO IP_PUBLICO <<<"$(obter_ips)"

    # Resolver IPs asociadas a los hostnames en la whitelist
    for HOSTNAME in "${WHITELIST_HOSTNAMES[@]}"; do
        RESOLVIDOS=$(getent ahosts "$HOSTNAME" | awk '{print $1}' | sort -u)
        WHITELIST_IPS+=($RESOLVIDOS)
    done

    # Mostrar información recolectada
    echo -e "\033[1;33mHostname actual: $(hostname)"
    echo -e "IP privada actual: $IP_PRIVADO"
    echo -e "IP pública actual: $IP_PUBLICO"
    echo -e "======================================\033[0m"
    sleep 3  # Permitir al usuario leer la información

    # Verificar si las IPs están autorizadas
    if [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PRIVADO} " ]] || [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PUBLICO} " ]]; then
        echo -e "\033[1;32m✔ ¡Ambiente validado con éxito! Continuando...\033[0m"
        VALIDATED=true
        return 0
    fi

    # Mostrar mensaje de error si no está autorizado
    while true; do
        clear
        echo -e "\033[1;31m======================================"
        echo -e "❌ ERROR: AMBIENTE NO AUTORIZADO"
        echo -e "--------------------------------------"
        echo -e "⚠️  Este sistema no está autorizado para uso externo."
        echo -e "⚠️  Está estrictamente prohibido utilizar este sistema fuera de los servidores autorizados."
        echo -e "--------------------------------------"
        echo -e "➡️  Hostname actual: $(hostname)"
        echo -e "➡️  IP privada actual: $IP_PRIVADO"
        echo -e "➡️  IP pública actual: $IP_PUBLICO"
        echo -e "--------------------------------------"
        echo -e "✅ Servidores autorizados: ${WHITELIST_HOSTNAMES[*]}"
        echo -e "✅ IPs autorizadas: ${WHITELIST_IPS[*]}"
        echo -e "--------------------------------------"
        echo -e "💡 Para adquirir una licencia o contratar nuestros servicios de hosting:"
        echo -e "   🌐 Accede haciendo clic aquí: \033[1;34mhttps://vortexuscloud.com.br\033[0m"
        echo -e "======================================\033[0m"
        sleep 10
    done
}

# ###########################################
# Función para revalidar el ambiente
# - Propósito: Realiza una validación secundaria del ambiente.
# - Editar: Solo los mensajes en los comandos echo si es necesario.
# - No editar: La lógica de validación debe permanecer igual.
# ###########################################
validar_secundario() {
    echo -e "\033[1;36mRevalidando ambiente...\033[0m"
    sleep 2
    validar_ambiente
}

# ###########################################
# Verificar whitelist antes de cualquier operación
# - Propósito: Asegura que el ambiente esté validado antes de proceder.
# - No editar: Este bloque asegura la validación inicial y no debe ser modificado.
# ###########################################
if [ "$VALIDATED" = false ]; then
    validar_ambiente
fi

# ###########################################
# Mensaje de bienvenida y simulación de validaciones
# - Editar: Solo los mensajes de bienvenida si es necesario.
# ###########################################
echo -e "\033[1;36m¡Bienvenido al sistema autorizado! Preparando validaciones subsecuentes...\033[0m"
sleep 5
validar_secundario

# ###########################################
# Inicio del script principal
# - Propósito: Mensaje final indicando que el sistema está listo para operar.
# - Editar: Solo el texto si es necesario.
# ###########################################
echo -e "\033[1;32m======================================"
echo -e "    ¡Sistema autorizado y operativo!"
echo -e "======================================\033[0m"

# ###########################################
# Configuraciones principales
# - Propósito: Configura las variables principales necesarias para el sistema.
# - Editar: Puedes modificar los valores de BASE_DIR y NUM_AMBIENTES según las necesidades del proyecto.
# - No editar: Las definiciones de colores ANSI deben permanecer intactas.
# ###########################################
BASE_DIR="/home/container"
NUM_AMBIENTES=8
TERMS_FILE="${BASE_DIR}/termos_accepted.txt"

# Colores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# ###########################################
# Función para animar texto
# - Propósito: Muestra un texto carácter por carácter simulando una animación.
# - Editar: Puedes ajustar el valor de "delay" para cambiar la velocidad de la animación.
# - No editar: La lógica de impresión debe permanecer intacta.
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
# Función para mostrar el cartel 3D con texto estático debajo
# - Propósito: Muestra un diseño de texto 3D en el terminal.
# - Editar: Puedes modificar el texto 3D, el pie de página y los enlaces.
# - No editar: La lógica de centrado y dibujo del texto no debe cambiarse.
# ###########################################
exibir_outdoor_3D() {
    clear
    local width=$(tput cols)  # Ancho del terminal
    local height=$(tput lines)  # Alto del terminal
    local start_line=$(( height / 3 ))
    local start_col=$(( (width - 60) / 2 ))  # Centrar el texto

    # Arte 3D del texto principal
    local outdoor_text=(
        " _   _  ___________ _____ _______   ___   _ _____ "
        "| | | ||  _  | ___ \\_   _|  ___\\ \\ / / | | /  ___|"
        "| | | || | | | |_/ / | | | |__  \\ V /| | | \\ --. "
        "| | | || | | |    /  | | |  __| /   \\| | | |--. \\"
        "\\ \\_/ /\\ \\_/ / |\\ \\  | | | |___/ /^\\ \\ |_| /\\__/ /"
        " \\___/  \\___/\\_| \\_| \\_/ \\____/\\/   \\/\\___/\\____/ "
    )

    # Mostrar el texto 3D centrado
    for i in "${!outdoor_text[@]}"; do
        tput cup $((start_line + i)) $start_col
        echo -e "${CYAN}${outdoor_text[i]}${NC}"
    done

    # Mostrar "Created by Mauro Gashfix" debajo del texto 3D
    local footer="Creado por Mauro Gashfix"
    tput cup $((start_line + ${#outdoor_text[@]} + 1)) $(( (width - ${#footer}) / 2 ))
    echo -e "${YELLOW}${footer}${NC}"

    # Mostrar los enlaces directamente debajo del pie de página
    local links="vortexuscloud.com.br & vortexuscloud.com"
    tput cup $((start_line + ${#outdoor_text[@]} + 2)) $(( (width - ${#links}) / 2 ))
    echo -e "${GREEN}${links}${NC}"

    # Mostrar la barra de progreso directamente debajo de los enlaces
    local progress_bar="Iniciando..."
    tput cup $((start_line + ${#outdoor_text[@]} + 4)) $(( (width - ${#progress_bar} - 20) / 2 ))
    echo -ne "${CYAN}${progress_bar}${NC}"
    for i in $(seq 1 20); do
        echo -ne "${GREEN}#${NC}"
        sleep 0.1
    done
    echo ""
}

# ###########################################
# Función para mostrar los términos de servicio
# - Propósito: Muestra los términos de servicio y verifica si el usuario los acepta.
# - Editar: Modifica los textos de los términos según las políticas del proyecto.
# - No editar: La lógica para manejar el archivo TERMS_FILE debe permanecer inalterada.
# ###########################################
exibir_termos() {
    exibir_outdoor_3D
    sleep 1
    echo -e "${BLUE}Este sistema está permitido solo en la plataforma Vortexus Cloud.${NC}"
    echo -e "${CYAN}======================================${NC}"

    if [ ! -f "$TERMS_FILE" ]; then
        while true; do
            echo -e "${YELLOW}¿ACEPTAS LOS TÉRMINOS DE SERVICIO? (SÍ/NO)${NC}"
            read -p "> " ACEITE
            if [ "$ACEITE" = "sí" ]; then
                echo -e "${GREEN}Términos aceptados el $(date).${NC}" > "$TERMS_FILE"
                echo -e "${CYAN}======================================${NC}"
                echo -e "${GREEN}TÉRMINOS ACEPTADOS. CONTINUANDO...${NC}"
                break
            elif [ "$ACEITE" = "no" ]; then
                echo -e "${RED}DEBES ACEPTAR LOS TÉRMINOS PARA CONTINUAR.${NC}"
            else
                echo -e "${RED}OPCIÓN INVÁLIDA. ESCRIBE 'SÍ' O 'NO'.${NC}"
            fi
        done
    else
        echo -e "${GREEN}TÉRMINOS YA ACEPTADOS ANTERIORMENTE. CONTINUANDO...${NC}"
    fi
}

# ###########################################
# Función para crear carpetas de los entornos
# - Propósito: Crea directorios para cada entorno si no existen.
# - Editar: Puedes modificar el nombre de las carpetas cambiando la variable AMBIENTE_PATH.
# - No editar: La lógica para crear carpetas debe permanecer inalterada.
# ###########################################
criar_pastas() {
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ ! -d "$AMBIENTE_PATH" ]; then
            mkdir -p "$AMBIENTE_PATH"
            echo -e "${GREEN}CARPETA DEL ENTORNO ${i} CREADA.${NC}"
        fi
    done
}

# ###########################################
# Función para actualizar el estado del entorno
# - Propósito: Actualiza el estado del entorno (por ejemplo, ON/OFF).
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para escribir el estado debe permanecer inalterada.
# ###########################################
atualizar_status() {
    AMBIENTE_PATH=$1
    NOVO_STATUS=$2
    echo "$NOVO_STATUS" > "${AMBIENTE_PATH}/status"
    echo -e "${CYAN}Estado del entorno actualizado a: ${GREEN}${NOVO_STATUS}${NC}"
}

# ###########################################
# Función para recuperar el estado del entorno
# - Propósito: Lee el estado del entorno desde el archivo correspondiente.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para leer el estado debe permanecer inalterada.
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
# Verificar y reiniciar sesiones en background
# - Propósito: Verifica las sesiones activas en segundo plano y las reinicia si es necesario.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica que maneja las sesiones debe permanecer intacta.
# ###########################################
verificar_sessoes() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "VERIFICANDO SESIONES EN BACKGROUND..."
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ -f "${AMBIENTE_PATH}/.session" ]; then
            STATUS=$(recuperar_status "$AMBIENTE_PATH")
            if [ "$STATUS" = "ON" ]; then
                COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                
                if [ -n "$COMANDO" ]; then
                    echo -e "${YELLOW}Ejecutando sesión en background para el entorno ${i}...${NC}"
                    pkill -f "$COMANDO" 2>/dev/null
                    cd "$AMBIENTE_PATH" || continue
                    nohup $COMANDO > nohup.out 2>&1 &
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}SESIÓN EN BACKGROUND ACTIVA PARA EL ENTORNO ${i}.${NC}"
                    else
                        echo -e "${RED}Error al intentar activar la sesión en el entorno ${i}.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Comando vacío encontrado en el archivo .session del entorno ${i}.${NC}"
                fi
            else
                echo -e "${RED}El entorno ${i} está en estado OFF. Ignorando...${NC}"
            fi
        else
            echo -e "${RED}No se encontró ningún archivo .session en el entorno ${i}.${NC}"
        fi
    done
    echo -e "${CYAN}======================================${NC}"
}

# ###########################################
# Menú principal
# - Propósito: Muestra el menú principal para gestionar los entornos.
# - Editar: Puedes modificar los textos de los comandos echo y las opciones del menú.
# - No editar: La lógica que maneja la selección de opciones debe permanecer intacta.
# ###########################################
menu_principal() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       GESTIÓN DE ENTORNOS"
    echo -e "${CYAN}======================================${NC}"
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        echo -e "${YELLOW}ENTORNO ${i}:${NC} ${GREEN}ESTADO - $STATUS${NC}"
    done
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}ELIGE UN ENTORNO PARA GESTIONAR (1-${NUM_AMBIENTES}):${NC}"
    echo -e "${RED}0 - SALIR${NC}"
    read -p "> " AMBIENTE_ESCOLHIDO

    if [ "$AMBIENTE_ESCOLHIDO" -ge 1 ] && [ "$AMBIENTE_ESCOLHIDO" -le "$NUM_AMBIENTES" ]; then
        gerenciar_ambiente "$AMBIENTE_ESCOLHIDO"
    elif [ "$AMBIENTE_ESCOLHIDO" = "0" ]; then
        anima_texto "SALIR..."
        exit 0
    else
        echo -e "${RED}ELECCIÓN INVÁLIDA. INTENTA DE NUEVO.${NC}"
        menu_principal
    fi
}

# ###########################################
# Elegir bot preconfigurado
# - Propósito: Permite seleccionar bots preconfigurados por idioma.
# - Editar: Puedes añadir o eliminar idiomas y opciones de bots.
# - No editar: La lógica para manejar las selecciones debe permanecer intacta.
# ###########################################
escolher_bot_pronto() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       ELEGIR BOT PRECONFIGURADO"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - BOTS EN PORTUGUÉS${NC}"
    echo -e "${YELLOW}2 - BOTS EN ESPAÑOL${NC}"
    echo -e "${RED}0 - VOLVER${NC}"
    read -p "> " OPCAO_BOT

    case $OPCAO_BOT in
        1)
            listar_bots "$AMBIENTE_PATH" "portugues"
            ;;
        2)
            listar_bots "$AMBIENTE_PATH" "espanol"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Listar bots disponibles
# - Propósito: Muestra una lista de bots disponibles para cada idioma.
# - Editar: Puedes añadir o eliminar bots en las listas BOTS.
# - No editar: La lógica para manejar las listas y selecciones debe permanecer intacta.
# ###########################################
listar_bots() {
    AMBIENTE_PATH=$1
    LINGUA=$2
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       BOTS DISPONIBLES - ${LINGUA^^}"
    echo -e "${CYAN}======================================${NC}"

    # Lista de bots disponibles
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
    elif [ "$LINGUA" = "espanol" ]; then
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
    echo -e "${RED}0 - VOLVER${NC}"

    read -p "> " BOT_ESCOLHIDO

    if [ "$BOT_ESCOLHIDO" -ge 1 ] && [ "$BOT_ESCOLHIDO" -le "${#BOTS[@]}" ]; then
        REPOSITORIO="${BOTS[$((BOT_ESCOLHIDO-1))]#*- }"
        verificar_instalacao_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    elif [ "$BOT_ESCOLHIDO" = "0" ]; then
        escolher_bot_pronto "$AMBIENTE_PATH"
    else
        echo -e "${RED}Opción inválida.${NC}"
        listar_bots "$AMBIENTE_PATH" "$LINGUA"
    fi
}


# ###########################################
# REGLA PARA AÑADIR IDIOMAS Y BOTS
# - Propósito: Explicar cómo agregar más idiomas y bots al sistema.
# 
# **Para añadir un nuevo idioma**:
#   1. Ve a la función `listar_bots`.
#   2. Agrega un nuevo bloque `elif` para el idioma deseado.
#      Por ejemplo, si el idioma es "francés":
#      ```bash
#      elif [ "$LINGUA" = "frances" ]; then
#          BOTS=(
#              "BOT FRANCE - https://github.com/user/bot-france.git"
#              "BOT PARIS - https://github.com/user/bot-paris.git"
#          )
#      fi
#      ```
#
# **Para añadir bots**:
#   1. Dentro de cada lista de bots (`BOTS`), agrega la URL del nuevo bot siguiendo el formato:
#      `"NOMBRE DEL BOT - URL_DEL_REPOSITORIO.git"`
#      Ejemplo:
#      ```bash
#      "NEW BOT - https://github.com/user/newbot.git"
#      ```
#
# **Nota importante**:
# - Mantén el formato y las comillas dobles para cada entrada.
# - La URL debe ser válida y accesible.
# - Asegúrate de probar la instalación del bot después de agregarlo.
# ###########################################

# ###########################################
# Función para verificar la instalación de un bot
# - Propósito: Verifica si ya existe un bot instalado en el entorno. Si es así, pregunta si debe eliminarse para instalar uno nuevo.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica que verifica y reemplaza la instalación del bot debe permanecer intacta.
# ###########################################
verificar_instalacao_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Ya existe un bot instalado en este entorno.${NC}"
        echo -e "${YELLOW}¿Desea eliminar el bot existente para instalar el nuevo? (sí/no)${NC}"
        read -p "> " RESPOSTA
        if [ "$RESPOSTA" = "sí" ]; then
            remover_bot "$AMBIENTE_PATH"
            instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
        else
            echo -e "${RED}Volviendo al menú principal...${NC}"
            menu_principal
        fi
    else
        instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    fi
}

# ###########################################
# Función para instalar un nuevo bot
# - Propósito: Clona el repositorio del bot y verifica los módulos necesarios.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica de instalación y clonación debe permanecer intacta.
# ###########################################
instalar_novo_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    NOME_BOT=$(basename "$REPOSITORIO" .git)
    echo -e "${CYAN}Iniciando la instalación del bot: ${GREEN}$NOME_BOT${NC}..."
    git clone "$REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}¡Bot $NOME_BOT instalado con éxito en el entorno $AMBIENTE_PATH!${NC}"
        verificar_node_modules "$AMBIENTE_PATH"
    else
        echo -e "${RED}Error al clonar el repositorio del bot $NOME_BOT. Verifique la URL e inténtelo nuevamente.${NC}"
    fi
}

# ###########################################
# Verificar e instalar node_modules
# - Propósito: Verifica si los módulos necesarios están instalados. Si no, ofrece opciones para instalarlos.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para verificar e instalar módulos debe permanecer igual.
# ###########################################
verificar_node_modules() {
    AMBIENTE_PATH=$1
    if [ ! -d "${AMBIENTE_PATH}/node_modules" ]; then
        echo -e "${YELLOW}Módulos no instalados en este bot.${NC}"
        echo -e "${YELLOW}Elija una opción para la instalación:${NC}"
        echo -e "${GREEN}1 - npm install${NC}"
        echo -e "${GREEN}2 - yarn install${NC}"
        echo -e "${RED}0 - Volver${NC}"
        read -p "> " OPCAO_MODULOS
        case $OPCAO_MODULOS in
            1)
                echo -e "${CYAN}Instalando módulos con npm...${NC}"
                cd "$AMBIENTE_PATH" && npm install
                [ $? -eq 0 ] && echo -e "${GREEN}¡Módulos instalados con éxito!${NC}" || echo -e "${RED}Error al instalar módulos con npm.${NC}"
                ;;
            2)
                echo -e "${CYAN}Instalando módulos con yarn...${NC}"
                cd "$AMBIENTE_PATH" && yarn install
                [ $? -eq 0 ] && echo -e "${GREEN}¡Módulos instalados con éxito!${NC}" || echo -e "${RED}Error al instalar módulos con yarn.${NC}"
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Opción inválida.${NC}"
                verificar_node_modules "$AMBIENTE_PATH"
                ;;
        esac
    else
        echo -e "${GREEN}Todos los módulos necesarios ya están instalados.${NC}"
    fi
    pos_clone_menu "$AMBIENTE_PATH"
}

# ###########################################
# Función para eliminar el bot actual
# - Propósito: Elimina todos los archivos del bot en el entorno seleccionado.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica de eliminación de archivos debe permanecer intacta.
# ###########################################
remover_bot() {
    AMBIENTE_PATH=$1

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Bot detectado en este entorno.${NC}"
        echo -e "${RED}¿Realmente desea eliminar el bot actual? (sí/no)${NC}"
        read -p "> " CONFIRMAR
        if [ "$CONFIRMAR" = "sí" ]; then
            find "$AMBIENTE_PATH" -mindepth 1 -exec rm -rf {} + 2>/dev/null
            [ -z "$(ls -A "$AMBIENTE_PATH")" ] && echo -e "${GREEN}Bot eliminado con éxito.${NC}" || echo -e "${RED}Error al eliminar el bot.${NC}"
        else
            echo -e "${RED}Eliminación cancelada.${NC}"
        fi
    else
        echo -e "${RED}No se encontró ningún bot en este entorno.${NC}"
    fi
    menu_principal
}

# ###########################################
# Función para clonar repositorios
# - Propósito: Permite clonar repositorios públicos o privados en el entorno seleccionado.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para manejar las URL y los tokens debe permanecer intacta.
# ###########################################
clonar_repositorio() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       CLONAR REPOSITORIO"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Clonar repositorio público${NC}"
    echo -e "${YELLOW}2 - Clonar repositorio privado${NC}"
    echo -e "${RED}0 - Volver${NC}"
    read -p "> " OPCAO_CLONAR

    case $OPCAO_CLONAR in
        1)
            echo -e "${CYAN}Proporcione la URL del repositorio público:${NC}"
            read -p "> " URL_REPOSITORIO
            if [[ $URL_REPOSITORIO != https://github.com/* ]]; then
                echo -e "${RED}¡URL inválida!${NC}"
                clonar_repositorio "$AMBIENTE_PATH"
                return
            fi
            echo -e "${CYAN}Clonando repositorio público...${NC}"
            git clone "$URL_REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}¡Repositorio clonado con éxito!${NC}" || echo -e "${RED}Error al clonar el repositorio.${NC}"
            ;;
        2)
            echo -e "${CYAN}Proporcione la URL del repositorio privado:${NC}"
            read -p "> " URL_REPOSITORIO
            echo -e "${CYAN}Usuario de GitHub:${NC}"
            read -p "> " USERNAME
            echo -e "${CYAN}Proporcione el token de acceso:${NC}"
            read -s -p "> " TOKEN
            echo
            GIT_URL="https://${USERNAME}:${TOKEN}@$(echo $URL_REPOSITORIO | cut -d/ -f3-)"
            echo -e "${CYAN}Clonando repositorio privado...${NC}"
            git clone "$GIT_URL" "$AMBIENTE_PATH" 2>/dev/null
            [ $? -eq 0 ] && echo -e "${GREEN}¡Repositorio privado clonado con éxito!${NC}" || echo -e "${RED}Error al clonar el repositorio privado.${NC}"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Menú post-clonación
# - Propósito: Proporciona opciones para realizar acciones después de clonar un repositorio.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para manejar las opciones debe permanecer intacta.
# ###########################################
pos_clone_menu() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "¿QUÉ DESEA HACER AHORA?"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Ejecutar el bot${NC}"
    echo -e "${YELLOW}2 - Instalar módulos${NC}"
    echo -e "${RED}0 - Volver al menú principal${NC}"
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
            echo -e "${RED}Opción inválida.${NC}"
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Función para instalar módulos
# - Propósito: Instala los módulos necesarios usando npm o yarn.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para manejar la instalación de módulos debe permanecer intacta.
# ###########################################
instalar_modulos() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "INSTALAR MÓDULOS"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - Instalar con npm install${NC}"
    echo -e "${YELLOW}2 - Instalar con yarn install${NC}"
    echo -e "${RED}0 - Volver al menú principal${NC}"
    read -p "> " OPCAO_MODULOS

    case $OPCAO_MODULOS in
        1)
            echo -e "${CYAN}Instalando módulos con npm...${NC}"
            cd "$AMBIENTE_PATH" && npm install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}¡Módulos instalados con éxito!${NC}"
            else
                echo -e "${RED}Error al instalar módulos con npm.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        2)
            echo -e "${CYAN}Instalando módulos con yarn...${NC}"
            cd "$AMBIENTE_PATH" && yarn install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}¡Módulos instalados con éxito!${NC}"
            else
                echo -e "${RED}Error al instalar módulos con yarn.${NC}"
            fi
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            instalar_modulos "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Función para iniciar el bot
# - Propósito: Permite iniciar, reiniciar o configurar un bot para el entorno seleccionado.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica para manejar sesiones y comandos de bots debe permanecer intacta.
# ###########################################
iniciar_bot() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        if [ "$STATUS" = "OFF" ]; then
            echo -e "${YELLOW}Sesión existente con estado OFF.${NC}"
            echo -e "${YELLOW}1 - Reiniciar el bot${NC}"
            echo -e "${RED}0 - Volver${NC}"
            read -p "> " OPCAO_EXISTENTE
            case $OPCAO_EXISTENTE in
                1)
                    COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                    nohup sh -c "cd $AMBIENTE_PATH && $COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &
                    clear
                    atualizar_status "$AMBIENTE_PATH" "ON"
                    echo -e "${GREEN}¡Bot reiniciado con éxito!${NC}"
                    menu_principal
                    ;;
                0)
                    menu_principal
                    ;;
                *)
                    echo -e "${RED}Opción inválida.${NC}"
                    iniciar_bot "$AMBIENTE_PATH"
                    ;;
            esac
        elif [ "$STATUS" = "ON" ]; then
            echo -e "${RED}Ya existe una sesión activa en este ambiente.${NC}"
            echo -e "${RED}Por favor, finalice la sesión actual antes de iniciar otra.${NC}"
            echo -e "${YELLOW}0 - Volver${NC}"
            read -p "> " OPCAO
            [ "$OPCAO" = "0" ] && menu_principal
        fi
    else
        echo -e "${CYAN}Elija cómo desea iniciar el bot:${NC}"
        echo -e "${YELLOW}1 - npm start${NC}"
        echo -e "${YELLOW}2 - Especificar archivo (ej: index.js o start.sh)${NC}"
        echo -e "${YELLOW}3 - Instalar módulos y ejecutar el bot${NC}"
        echo -e "${RED}0 - Volver${NC}"
        read -p "> " INICIAR_OPCAO

        case $INICIAR_OPCAO in
            1)
                echo "npm start" > "${AMBIENTE_PATH}/.session"
                clear
                echo -e "${YELLOW}Reinicie el servidor al finalizar para aplicar los cambios${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    cd "$AMBIENTE_PATH" && npm start
                    echo -e "${YELLOW}1 - Reiniciar el bot${NC}"
                    echo -e "${YELLOW}2 - Guardar y volver al menú principal${NC}"
                    echo -e "${RED}0 - Volver${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Reiniciando el proceso...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Guardando y volviendo al menú principal...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Opción inválida.${NC}"
                            ;;
                    esac
                done
                ;;
            2)
                echo -e "${YELLOW}Escriba el nombre del archivo para ejecutar:${NC}"
                read ARQUIVO
                if [[ $ARQUIVO == *.sh ]]; then
                    echo "sh $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                else
                    echo "node $ARQUIVO" > "${AMBIENTE_PATH}/.session"
                fi
                clear
                echo -e "${YELLOW}Reinicie el servidor al finalizar para aplicar los cambios${NC}"
                atualizar_status "$AMBIENTE_PATH" "ON"
                while true; do
                    if [[ $ARQUIVO == *.sh ]]; then
                        cd "$AMBIENTE_PATH" && sh "$ARQUIVO"
                    else
                        cd "$AMBIENTE_PATH" && node "$ARQUIVO"
                    fi
                    echo -e "${YELLOW}1 - Reiniciar el bot${NC}"
                    echo -e "${YELLOW}2 - Guardar y volver al menú principal${NC}"
                    echo -e "${RED}0 - Volver${NC}"
                    read -p "> " OPC_REINICIAR
                    case $OPC_REINICIAR in
                        1)
                            echo -e "${CYAN}Reiniciando el proceso...${NC}"
                            ;;
                        2)
                            echo -e "${GREEN}Guardando y volviendo al menú principal...${NC}"
                            menu_principal
                            ;;
                        0)
                            menu_principal
                            ;;
                        *)
                            echo -e "${RED}Opción inválida.${NC}"
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
                    echo -e "${RED}Error al instalar módulos. Volviendo al menú...${NC}"
                    pos_clone_menu "$AMBIENTE_PATH"
                fi
                ;;
            0)
                menu_principal
                ;;
            *)
                echo -e "${RED}Opción inválida.${NC}"
                iniciar_bot "$AMBIENTE_PATH"
                ;;
        esac
    fi
}

# ###########################################
# Función para detener el bot
# - Propósito: Permite detener la sesión activa del bot.
# - Editar: Solo los textos de los comandos echo si es necesario.
# - No editar: La lógica para manejar sesiones debe permanecer intacta.
# ###########################################
parar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "DETENER EL BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        pkill -f "$COMANDO" 2>/dev/null
        clear
atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Bot detenido con éxito.${NC}"
        echo -e "${YELLOW}Reinicie el servidor cuando termine para aplicar cambios.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}No se encontró ninguna sesión activa para detener.${NC}"
    fi
    menu_principal
}

# ###########################################
# Función para reiniciar el bot
# - Propósito: Reinicia la sesión activa del bot en el entorno seleccionado.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica de reinicio del bot debe permanecer intacta.
# ###########################################
reiniciar_bot() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "REINICIAR EL BOT"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        pkill -f "$COMANDO" 2>/dev/null
        cd "$AMBIENTE_PATH" && nohup $COMANDO > nohup.out 2>&1 &
        clear
atualizar_status "$AMBIENTE_PATH" "ON"
        echo -e "${GREEN}¡Bot reiniciado con éxito!${NC}"
    else
        echo -e "${RED}No se encontró ninguna sesión activa para reiniciar.${NC}"
    fi
    menu_principal
}

# ###########################################
# Función para visualizar el terminal
# - Propósito: Muestra el archivo de salida del bot en tiempo real.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica para visualizar el archivo de salida debe permanecer intacta.
# ###########################################
ver_terminal() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "VISUALIZAR EL TERMINAL"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/nohup.out" ]; then
    clear
    echo -e "${YELLOW}Cuando reinicie el servidor, debe acceder al ENTORNO y reiniciar el bot desde la opción 2.${NC}"
atualizar_status "$AMBIENTE_PATH" "OFF"
        tail -f "${AMBIENTE_PATH}/nohup.out"
    else
        echo -e "${RED}No se encontró ninguna salida del terminal.${NC}"
    fi
    menu_principal
}

# ###########################################
# Función para eliminar la sesión
# - Propósito: Elimina la sesión activa del bot y los datos asociados en el entorno seleccionado.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica de eliminación de la sesión debe permanecer intacta.
# ###########################################
deletar_sessao() {
    AMBIENTE_PATH=$1
    echo -e "${CYAN}======================================${NC}"
    anima_texto "ELIMINAR SESIÓN"
    echo -e "${CYAN}======================================${NC}"
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        pkill -f "$COMANDO" 2>/dev/null
        rm -f "${AMBIENTE_PATH}/.session"
        clear
atualizar_status "$AMBIENTE_PATH" "OFF"
        echo -e "${GREEN}Sesión eliminada con éxito. Por favor, reinicie el servidor para aplicar cambios.${NC}"
        exec /bin/bash
    else
        echo -e "${RED}No se encontró ninguna sesión activa para eliminar.${NC}"
    fi
    menu_principal
}

# ###########################################
# Función para gestionar el entorno
# - Propósito: Proporciona un menú para gestionar los bots en el entorno seleccionado.
# - Editar: Puedes modificar los textos de los comandos echo para adaptarlos a tu proyecto.
# - No editar: La lógica para manejar las opciones debe permanecer intacta.
# ###########################################
gerenciar_ambiente() {
    AMBIENTE_PATH="${BASE_DIR}/ambiente$1"
    echo -e "${CYAN}======================================${NC}"
    anima_texto "GESTIONANDO ENTORNO $1"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}1 - ELEGIR BOT PREDEFINIDO DE VORTEXUS${NC}"
    echo -e "${YELLOW}2 - INICIAR EL BOT${NC}"
    echo -e "${YELLOW}3 - DETENER EL BOT${NC}"
    echo -e "${YELLOW}4 - REINICIAR EL BOT${NC}"
    echo -e "${YELLOW}5 - VISUALIZAR EL TERMINAL${NC}"
    echo -e "${YELLOW}6 - ELIMINAR SESIÓN${NC}"
    echo -e "${YELLOW}7 - ELIMINAR BOT ACTUAL${NC}"
    echo -e "${YELLOW}8 - CLONAR REPOSITORIO${NC}"
    echo -e "${RED}0 - VOLVER${NC}"
    read -p "> " OPCAO

    case $OPCAO in
        1) escolher_bot_pronto "$AMBIENTE_PATH" ;; # Llama a la función para elegir un bot.
        2) iniciar_bot "$AMBIENTE_PATH" ;;          # Llama a la función para iniciar el bot.
        3) parar_bot "$AMBIENTE_PATH" ;;            # Llama a la función para detener el bot.
        4) reiniciar_bot "$AMBIENTE_PATH" ;;        # Llama a la función para reiniciar el bot.
        5) ver_terminal "$AMBIENTE_PATH" ;;         # Llama a la función para visualizar el terminal.
        6) deletar_sessao "$AMBIENTE_PATH" ;;       # Llama a la función para eliminar la sesión.
        7) remover_bot "$AMBIENTE_PATH" ;;          # Llama a la función para eliminar el bot actual.
        8) clonar_repositorio "$AMBIENTE_PATH" ;;   # Llama a la función para clonar un repositorio.
        0) menu_principal ;;                        # Vuelve al menú principal.
        *) 
            echo -e "${RED}Opción inválida.${NC}"
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
