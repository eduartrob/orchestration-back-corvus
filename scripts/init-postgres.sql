-- ============================================
-- Corvus Platform - PostgreSQL Initialization
-- Crea todas las bases de datos lógicas para los microservicios
-- ============================================

-- corvus_auth_db ya se crea automáticamente por la variable de entorno POSTGRES_DB en docker-compose

-- Crear las bases de datos adicionales
CREATE DATABASE corvus_notifications_db;
CREATE DATABASE corvus_llm_db;
CREATE DATABASE corvus_subject_matter_db;
CREATE DATABASE corvus_students_information_db;
CREATE DATABASE corvus_students_groups_db;
CREATE DATABASE corvus_integrator_project_db;

-- Otorgar privilegios (Asumiendo usuario 'postgres')
GRANT ALL PRIVILEGES ON DATABASE corvus_auth_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_notifications_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_llm_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_subject_matter_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_students_information_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_students_groups_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE corvus_integrator_project_db TO postgres;

-- Conectarse a cada base de datos y agregar extensiones de utilidad (ej. UUID)
\c corvus_auth_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_notifications_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_llm_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_subject_matter_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_students_information_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_students_groups_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c corvus_integrator_project_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$
BEGIN
  RAISE NOTICE '✅ PostgreSQL inicializado correctamente para Corvus Platform';
  RAISE NOTICE '   Se crearon 7 bases de datos lógicas listas para Prisma.';
END $$;
