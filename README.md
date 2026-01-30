# Ultimate Huly Self-Hosted (for Dokploy)

This repository contains an optimized, production-ready configuration for self-hosting **Huly v7** using **Dokploy**. 

We maintain this project updated to ensure security and stability for Docker Compose deployments.

---
🚀 **Developed and maintained by [se2code.com](https://www.se2code.com)**.  
*Specialists in high-performance infrastructure and self-hosted solutions.*
---

## ✨ Key Features

This configuration has been modernized and enhanced by our team:
- **Reinforced Security**: Public registration disabled by default (`DISABLE_SIGNUP=true`). Your instance is only accessible to those you invite.
- **Custom Mail Service**: Includes a Node.js-based mail service (`mail-service`) that resolves authentication incompatibilities and ensures invitations always reach their destination.
- **Modern Architecture**: Native support for CockroachDB, Redpanda, MinIO, and Elasticsearch.
- **Optimized for Dokploy**: Automatic integration with Traefik and volume management.

## 🚀 Hardware Requirements

For a smooth operation of all services:
* **RAM**: Minimum **4GB** (8GB recommended for production).
* **CPU**: 2 Cores or more.
* **Storage**: SSD recommended.

## 🛠️ Dokploy Installation Guide

### 1. Server Preparation
It is **CRITICAL** to increase the memory map limit for Elasticsearch. Run on your host server:
```bash
sudo sysctl -w vm.max_map_count=262144
```
*(Make it persistent by editing `/etc/sysctl.conf`)*.

### 2. Dokploy Setup
1.  Create a new project and select the **"Compose"** deployment type.
2.  **Docker Compose**: Copy the content from our [`docker-compose.yml`](./docker-compose.yml).
3.  **Environment Variables**: Use our [`.env.example`](./.env.example) as a template. Make sure to configure:
    - `HOST_ADDRESS`: Your domain (e.g., `huly.yourdomain.com`).
    - `SMTP_*`: Your credentials from your **SMTP mail provider**.
    - `SECRET`: A random and secure string.

## 🆘 Need Help?

If you encounter technical issues during deployment:
*   **Huly Community**: [Official Huly Discord](https://huly.io/discord)
*   **Official Documentation**: [Huly Docs](https://docs.huly.io)
*   **Specialized Technical Support**: If you need a professional deployment, direct support, or infrastructure consulting, visit **[se2code.com](https://www.se2code.com)**.

## 📂 Project Structure
- `mail-service/`: Source code for our custom mail service.
- `docker-compose.yml`: Main stack definition.
- `.env.example`: Environment variables template.

---
Made with ❤️ by the **[se2code.com](https://www.se2code.com)** team.
