#!/bin/bash

# ==============================================================================
# CORVUS PLATFORM - SCRIPT DE DESPLIEGUE PARA AWS EC2 (Ubuntu/Debian)
# ==============================================================================

set -e

echo "🚀 Iniciando proceso de despliegue automatizado de Corvus..."

# 1. Verificar e instalar dependencias (Docker y Docker Compose)
if ! command -v docker &> /dev/null; then
    echo "⚙️ Instalando Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
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

# 2. Actualizar repositorio (Opcional, si se corre dentro del repo)
echo "🔄 Sincronizando con el repositorio Git..."
git pull origin main || echo "⚠️ No se pudo hacer git pull. Asegúrate de estar en el directorio correcto y tener permisos."

# 3. Solicitud Interactiva de Archivos .env
echo "======================================================================"
echo "🔐 CONFIGURACIÓN DE VARIABLES DE ENTORNO (.env)"
echo "Por seguridad, los archivos .env no se suben a Git."
echo "======================================================================"

prompt_env_file() {
    local service_path=$1
    local env_file="${service_path}/.env"
    
    if [ -f "$env_file" ]; then
        echo "✅ El archivo $env_file ya existe. Omitiendo..."
    else
        echo "⚠️  FALTA ARCHIVO: $env_file"
        echo "Por favor, pega el contenido de tu archivo .env para este servicio."
        echo "Cuando termines, presiona Enter, escribe 'EOF' y presiona Enter de nuevo:"
        
        # Leer múltiples líneas hasta encontrar EOF
        cat << 'EOF_MARKER' > "$env_file"
EOF_MARKER
        
        while IFS= read -r line; do
            if [[ "$line" == "EOF" ]]; then
                break
            fi
            echo "$line" >> "$env_file"
        done
        
        echo "✅ Archivo $env_file guardado exitosamente."
    fi
}

prompt_env_file "../apiGateway-back-corvus"
prompt_env_file "../authentication-back-corvus"
prompt_env_file "../notifications-back-corvus"
prompt_env_file "../integratorProjectClustering-back-corvus"

# 4. Levantar la infraestructura
echo "🏗️ Construyendo y levantando los contenedores de Docker..."
docker-compose up --build -d

echo "======================================================================"
echo "🎉 DESPLIEGUE FINALIZADO CORRECTAMENTE 🎉"
echo "El API Gateway está escuchando en el puerto 3000 de esta máquina."
echo "Asegúrate de ir a la consola de AWS EC2 -> Security Groups -> Inbound Rules"
echo "Y abrir el puerto TCP 3000 hacia 0.0.0.0/0."
echo "======================================================================"
