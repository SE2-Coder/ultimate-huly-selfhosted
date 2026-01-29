# Ultimate Huly Self-Hosted (for Dokploy)

This repository contains a production-ready configuration for self-hosting **Huly v7** (Platform for Project Management) using **Dokploy**.

This project is maintained by [se2code.com](https://www.se2code.com), specializing in high-performance self-hosted infrastructure.

It has been modernized to support the latest Huly architecture:
- **CockroachDB** (replaces MongoDB)
- **Redpanda** (Kafka compatible)
- **MinIO** & **Elasticsearch**
- **Traefik** Integration (via Dokploy labels).

## 🚀 Requisitos de Hardware

Para un funcionamiento estable de todo el stack (Elasticsearch, CockroachDB, Redpanda), se recomienda:
* **RAM**: Mínimo **4GB** (8GB recomendado para entornos de producción). El stack completo consume aproximadamente 3.5GB en reposo.
* **CPU**: 2 Cores o más.
* **OS**: Linux con Docker y Dokploy instalado.

## 🛠️ Instalación en Dokploy

### 1. Prerequisites
**CRITICAL**: On your Dokploy Host Server, you must run:
```bash
sudo sysctl -w vm.max_map_count=262144
```
*Note: Make this persistent by adding `vm.max_map_count=262144` to `/etc/sysctl.conf`.*

### 2. Dokploy Setup
1.  Create a Project in Dokploy (e.g., `huly-app`).
2.  Select **"Compose"** deployment type.

### 3. Configuration
1.  **Docker Compose**: Copy content from [`docker-compose.yml`](./docker-compose.yml).
2.  **Environment**: Copy content from [`env.example`](./.env.example) to your Dokploy Environment variables tab.
    - Rename/Set values for `HOST_ADDRESS` (Your Domain).
    - Update `SECRET` and passwords.

### 4. Deploy
Click **Deploy** in Dokploy. 

## 📂 File Structure
- `docker-compose.yml`: The main stack definition.
- `.env.example`: Template for environment variables.

---
Desarrollado y mantenido con ❤️ por [se2code.com](https://www.se2code.com). Si necesitas ayuda con tu despliegue, visítanos.
