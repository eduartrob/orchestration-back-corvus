#!/bin/bash

# ==============================================================================
# CORVUS PLATFORM - DETENER SERVICIOS
# ==============================================================================

echo "🛑 Deteniendo todos los servicios de Corvus..."

cd "$(dirname "$0")/.."

docker-compose down

echo "✅ Todos los servicios han sido detenidos correctamente."
