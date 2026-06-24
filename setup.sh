#!/bin/bash

# ==============================================================================
# CORVUS PLATFORM - SCRIPT DE INSTALACIÓN MAESTRO v2.0
# Descarga, clona, configura y despliega toda la plataforma Corvus.
# Incluye fixes de producción: swap, permisos, limpieza de Docker cache.
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

# 2. Configurar Swap de 2GB para evitar OOM durante compilación de Docker
if [ ! -f /swapfile ]; then
    echo "💾 Configurando 2GB de Swap para compilación segura..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    # Persistir el swap entre reinicios
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "✅ Swap de 2GB configurado y persistido."
else
    echo "✅ Swap ya está configurado."
fi

# 3. Crear estructura de carpetas y clonar repositorios
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

# 4. Corregir permisos en caso de que un pull anterior se haya hecho con sudo
echo "🔒 Verificando permisos de directorios..."
sudo chown -R $USER:$USER .
echo "✅ Permisos correctos."

# 5. Solicitud Interactiva de Archivos .env
echo "======================================================================"
echo "🔐 CONFIGURACIÓN DE VARIABLES DE ENTORNO (.env)"
echo "======================================================================"

prompt_env_file() {
    local service_path=$1
    local env_file="${service_path}/.env"
    
    if [ -f "$env_file" ]; then
        echo "✅ El archivo $env_file ya existe. Omitiendo..."
    else
        echo ""
        echo "⚠️  FALTA ARCHIVO: $env_file"
        echo "Por favor, pega el contenido de tu archivo .env."
        echo "Cuando termines, presiona ENTER en una línea vacía para continuar:"
        echo ""
        
        > "$env_file"
        
        while IFS= read -r line; do
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

# 6. Limpiar caché vieja de Docker para liberar espacio antes de construir
echo "🧹 Limpiando caché de Docker para garantizar espacio suficiente..."
sudo docker system prune -af --filter "until=24h" 2>/dev/null || true
echo "✅ Caché limpiada."

# 7. Levantar la infraestructura con sudo (requerido para Docker socket)
echo "🏗️ Construyendo y levantando los contenedores de Docker..."
cd orchestration-back-corvus
sudo docker-compose up --build -d

# 8. Sincronizar esquemas de base de datos (Prisma)
echo "🗄️ Esperando a que las bases de datos estén listas para sincronizar esquemas (10s)..."
sleep 10
echo "🔄 Sincronizando esquema de Autenticación..."
sudo docker exec corvus_auth_service npx prisma db push --accept-data-loss || echo "⚠️ Advertencia: No se pudo sincronizar Auth DB automáticamente."
echo "🔄 Sincronizando esquema de Notificaciones..."
sudo docker exec corvus_notifications_service npx prisma db push --accept-data-loss || echo "⚠️ Advertencia: No se pudo sincronizar Notifications DB automáticamente."

echo "======================================================================"
echo "🎉 INSTALACIÓN FINALIZADA CORRECTAMENTE 🎉"
echo ""
echo "📡 Tu API está disponible en:"
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "<tu-ip-publica>")
echo "   http://${PUBLIC_IP}:3000"
echo ""
echo "📋 Comandos útiles:"
echo "   Ver logs:      sudo docker-compose logs -f"
echo "   Ver servicios: sudo docker ps"
echo "   Reiniciar:     sudo docker-compose restart"
echo "   Detener:       sudo docker-compose down"
echo "======================================================================"
