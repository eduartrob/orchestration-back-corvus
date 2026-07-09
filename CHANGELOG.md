## [1.2.13] - 2026-07-09
- Preparación para nueva arquitectura de Proyectos Integradores.

# Changelog
All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-06-24
### Fixed
- **IA/Clustering**: Fixed `NameError` crash by pinning `transformers==4.38.2`. Added missing math dependencies (`python-multipart`, `umap-learn`, `hdbscan`, `plotly`) for full UMAP+HDBSCAN functionality.
- **RabbitMQ**: Stabilized long-running AI vectorization tasks by disabling connection heartbeats (`heartbeat=0`) and enforcing `durable=True`.
- **API Gateway**: Fixed duplicated route mapping (`/api/v1/api/v1`) that was breaking connections to the clustering service.
- **UX Optimization**: Clustering service now emits a `sync_complete` event instead of `sync_error` when an empty Google Drive folder is synced, preventing frontend freezes.

## [1.0.0] - 2026-06-22
### Added
- Created `docker-compose.yml` to orchestrate PostgreSQL and RabbitMQ containers.
- Added `scripts/init-postgres.sql` for automated creation of 7 logical databases required by downstream microservices.
- Linked RabbitMQ to read external configurations from `rabbitmq-config-corvus`.
