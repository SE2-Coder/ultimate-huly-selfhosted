# Ultimate Huly Self-Hosted (for Dokploy)

This repository contains a production-ready configuration for self-hosting **Huly v7** (Platform for Project Management) using **Dokploy**.

It has been modernized to support the latest Huly architecture:
- **CockroachDB** (replaces MongoDB)
- **Redpanda** (Kafka compatible)
- **MinIO** & **Elasticsearch**
- **Traefik** Integration (via Dokploy labels) - No separate Nginx container required.

## 🚀 Deployment Instructions

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
*Maintained by SE2-Coder*
