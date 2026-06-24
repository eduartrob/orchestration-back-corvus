# Orquestación y DevOps - Corvus Platform

Este repositorio es el centro de control de infraestructura de la plataforma Corvus. Contiene los archivos de configuración para levantar todos los servicios base mediante Docker.

## Infraestructura Central
* **PostgreSQL (v15):** Un contenedor único y centralizado que aloja las diferentes bases de datos lógicas (microservicios independientes).
* **RabbitMQ (v3):** Message Broker para el manejo de eventos asíncronos y colas entre microservicios (Ej. notificaciones, correos).
* **Microservicios:** API Gateway, Authentication, Notifications, Integrator Project Clustering (IA).

## Inicialización Automática
El script `/scripts/init-postgres.sql` se ejecuta automáticamente la primera vez que se levanta el contenedor de PostgreSQL para generar las bases de datos vacías requeridas.

---

## 🚀 Despliegue Automatizado en AWS EC2

Para hacer el despliegue en un servidor de producción (como un EC2 de Ubuntu en AWS) hemos creado un script que instala las dependencias necesarias, pide interactivamente los secretos `.env` y levanta todos los contenedores con un solo comando.

### Instrucciones de Despliegue

1. Entra a tu instancia EC2 por SSH.
2. Clona el repositorio de orquestación (y los microservicios si es necesario) y entra en la carpeta:
   ```bash
   git clone <URL_DEL_REPO> orchestration-back-corvus
   cd orchestration-back-corvus
   ```
3. Otorga permisos de ejecución al script si aún no los tiene:
   ```bash
   chmod +x deploy-ec2.sh
   ```
4. Ejecuta el script de despliegue interactivo:
   ```bash
   ./deploy-ec2.sh
   ```
5. **Variables de Entorno (.env):** El script detectará si faltan archivos `.env` (ya que estos no se suben a Git por seguridad). Te pedirá interactivamente que pegues el contenido de tu `.env` para cada microservicio. 
   - Pega tu texto.
   - Presiona Enter.
   - Escribe la palabra `EOF` y vuelve a presionar Enter.
6. El orquestador descargará las imágenes y construirá todo. Al finalizar, la API estará viva y lista para recibir peticiones.

---

## 🔐 Puertos y Seguridad en AWS (Security Groups)

Por diseño de arquitectura, los microservicios están blindados y no se exponen al internet público. 

**El ÚNICO puerto que debes abrir en las reglas de entrada (Inbound Rules) de tu Security Group en AWS EC2 es:**
- **Puerto 3000 (TCP):** Para el `api-gateway`, que es el único que gestionará el tráfico hacia la aplicación móvil.
- *(Y el puerto 22 para SSH, por supuesto).*

Cualquier petición que la aplicación móvil necesite hacer a Auth, Notificaciones o IA, lo hará golpeando la IP Elástica de EC2 por el puerto 3000 (Ej: `http://3.15.22.40:3000/api/v1/auth/login`).
