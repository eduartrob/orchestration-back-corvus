# Changelog
All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-06-22
### Added
- Created `docker-compose.yml` to orchestrate PostgreSQL and RabbitMQ containers.
- Added `scripts/init-postgres.sql` for automated creation of 7 logical databases required by downstream microservices.
- Linked RabbitMQ to read external configurations from `rabbitmq-config-corvus`.
