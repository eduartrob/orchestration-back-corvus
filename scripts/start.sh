#!/bin/bash

# ==============================================================================
# CORVUS PLATFORM - INICIAR SERVICIOS
# ==============================================================================

echo "🚀 Iniciando todos los servicios de Corvus..."

cd "$(dirname "$0")/.."

docker-compose up --build -d

echo "✅ Servicios iniciados en segundo plano."
echo "Para ver los logs, ejecuta: docker-compose logs -f"
