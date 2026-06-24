#!/bin/bash

# ==============================================================================
# CORVUS PLATFORM - SCRIPT DE INSTALACIÓN MAESTRO
# Descarga, clona, configura y despliega toda la plataforma Corvus.
# ==============================================================================

set -e

echo "🚀 Iniciando Instalación de Corvus Platform..."

# 1. Verificar e instalar Docker y Docker Compose
if ! command -v docker &> /dev/null; then
    echo "⚙️ Instalando Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "✅ Docker instalado."
else
    echo "✅ Docker ya está instalado."
fi

if ! command -v docker-compose &> /dev/null; then
    echo "⚙️ Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose instalado."
else
    echo "✅ Docker Compose ya está instalado."
fi

# 2. Crear estructura de carpetas y clonar repositorios
BASE_DIR="corvus-backend"
echo "📁 Creando directorio base: $BASE_DIR"
mkdir -p $BASE_DIR
cd $BASE_DIR

echo "📥 Clonando repositorios..."
REPOS=(
    "https://github.com/eduartrob/orchestration-back-corvus.git"
    "https://github.com/eduartrob/apiGateway-back-corvus.git"
    "https://github.com/eduartrob/authentication-back-corvus.git"
    "https://github.com/eduartrob/notifications-back-corvus.git"
    "https://github.com/eduartrob/integratorProjectClustering-back-corvus.git"
)

for REPO in "${REPOS[@]}"; do
    DIR_NAME=$(basename $REPO .git)
    if [ ! -d "$DIR_NAME" ]; then
        git clone $REPO
    else
        echo "✅ El directorio $DIR_NAME ya existe. Actualizando..."
        cd $DIR_NAME && git pull origin main && cd ..
    fi
done

# 3. Solicitud Interactiva de Archivos .env
echo "======================================================================"
echo "🔐 CONFIGURACIÓN DE VARIABLES DE ENTORNO (.env)"
echo "======================================================================"

prompt_env_file() {
    local service_path=$1
    local env_file="${service_path}/.env"
    
    if [ -f "$env_file" ]; then
        echo "✅ El archivo $env_file ya existe. Omitiendo..."
    else
        echo "⚠️  FALTA ARCHIVO: $env_file"
        echo "Por favor, pega el contenido de tu archivo .env (asegúrate de copiarlo SIN líneas vacías en el medio)."
        echo "Cuando termines, simplemente presiona ENTER (línea en blanco) para continuar:"
        
        # Vaciar el archivo si existe
        > "$env_file"
        
        while IFS= read -r line; do
            # Si el usuario manda una línea vacía (Enter), terminamos de capturar
            if [[ -z "$line" ]]; then
                break
            fi
            echo "$line" >> "$env_file"
        done
        
        echo "✅ Archivo $env_file guardado exitosamente."
    fi
}

prompt_env_file "apiGateway-back-corvus"
prompt_env_file "authentication-back-corvus"
prompt_env_file "notifications-back-corvus"
prompt_env_file "integratorProjectClustering-back-corvus"

# 4. Levantar la infraestructura
echo "🏗️ Construyendo y levantando los contenedores de Docker..."
cd orchestration-back-corvus
docker-compose up --build -d

echo "======================================================================"
echo "🎉 INSTALACIÓN FINALIZADA CORRECTAMENTE 🎉"
echo "Todos los servicios están corriendo en segundo plano."
echo "Para ver logs, usa: cd corvus-backend/orchestration-back-corvus && docker-compose logs -f"
echo "======================================================================"
