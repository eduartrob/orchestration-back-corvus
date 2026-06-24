# Orchestration - Corvus Microservices

Este directorio contiene la configuración de Docker Compose y scripts para orquestar todos los microservicios de la plataforma Corvus.

## 🚀 Instalación Rápida (Primera Vez)

Si es la primera vez que configuras el proyecto (o estás en un servidor EC2 limpio), ejecuta:

```bash
git clone https://github.com/eduartrob/orchestration-back-corvus.git
cd orchestration-back-corvus
chmod +x setup.sh
./setup.sh
```

Este comando:
1. Descarga el script de instalación maestro.
2. Instala Docker y Docker-Compose si es necesario.
3. Clona todos los repositorios de microservicios.
4. Te pide configurar el `.env` de cada servicio interactivamente.
5. Inicia toda la infraestructura.

---

## 🎯 Inicio Rápido (Ya Configurado)

### Prerrequisitos
- Docker y Docker Compose instalados en tu máquina.

### Iniciar Todos los Servicios
Desde el directorio `orchestration-back-corvus`:

```bash
./scripts/start.sh
```
Este comando:
- Construye las imágenes Docker de todos los servicios.
- Inicia PostgreSQL, RabbitMQ, Gateway, Auth, Notifications y Clustering.
- Los servicios quedan corriendo en segundo plano.

### Detener Todos los Servicios
```bash
./scripts/stop.sh
```

---

## 📋 Servicios Incluidos

El `docker-compose.yml` orquesta los siguientes servicios bajo una red privada:
- **PostgreSQL (`db`)**: Base de datos compartida.
- **RabbitMQ (`rabbitmq`)**: Sistema de mensajería (Eventos asíncronos).
- **Auth Service**: Autenticación y gestión de JWT.
- **Gateway**: API Gateway (Único servicio expuesto al público).
- **Notifications Service**: Envío de correos y OTPs.
- **Clustering Integrator**: Motor IA en Python para análisis de Océanos Azules.

---

## 🔧 Comandos Útiles

**Ver el estado de los servicios:**
```bash
docker-compose ps
```

**Ver logs de todos los servicios:**
```bash
docker-compose logs -f
```

**Ver logs de un servicio específico:**
```bash
docker-compose logs -f api-gateway
```

**Reconstruir un servicio específico tras un cambio en el código:**
```bash
docker-compose up -d --build auth-service
```

---

## 🔐 Puertos y Seguridad en AWS (Security Groups)

Por diseño de arquitectura, los microservicios están blindados y no se exponen al internet público. 

**El ÚNICO puerto que debes abrir en las reglas de entrada (Inbound Rules) de tu Security Group en AWS EC2 es:**
- **Puerto 3000 (TCP):** Para el `api-gateway`, que es el único que gestionará el tráfico hacia la aplicación móvil.

Cualquier petición que la aplicación móvil necesite hacer lo hará golpeando la IP Elástica de EC2 por el puerto 3000 (Ej: `http://3.15.22.40:3000/api/v1/auth/login`).
