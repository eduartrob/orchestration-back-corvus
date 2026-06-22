# Orquestación y DevOps - Corvus Platform

Este repositorio es el centro de control de infraestructura de la plataforma Corvus. Contiene los archivos de configuración para levantar todos los servicios base mediante Docker.

## Infraestructura Central
* **PostgreSQL (v15):** Un contenedor único y centralizado que aloja las diferentes bases de datos lógicas (microservicios independientes).
* **RabbitMQ (v3):** Message Broker para el manejo de eventos asíncronos y colas entre microservicios (Ej. notificaciones, correos).

## Inicialización Automática
El script `/scripts/init-postgres.sql` se ejecuta automáticamente la primera vez que se levanta el contenedor de PostgreSQL para generar las siguientes bases de datos vacías:
- `corvus_auth_db` (Creada por defecto vía env vars)
- `corvus_notifications_db`
- `corvus_llm_db`
- `corvus_subject_matter_db`
- `corvus_students_information_db`
- `corvus_students_groups_db`
- `corvus_integrator_project_db`

## Uso
Para levantar la base de datos y la cola de mensajes en desarrollo:
```bash
docker-compose up -d
```
