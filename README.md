# Ultimate Huly Self-Hosted (for Dokploy)

Este repositorio contiene una configuración optimizada y lista para producción para auto-hospedar **Huly v7** utilizando **Dokploy**. 

Mantenemos este proyecto actualizado para garantizar la seguridad y estabilidad en despliegues sobre Docker Compose.

---
🚀 **Desarrollado y mantenido por [se2code.com](https://www.se2code.com)**.  
*Especialistas en infraestructura de alto rendimiento y soluciones self-hosted.*
---

## ✨ Características Principales

Esta configuración ha sido modernizada y mejorada por nuestro equipo:
- **Seguridad Reforzada**: Registro público deshabilitado por defecto (`DISABLE_SIGNUP=true`). Tu instancia solo será accesible para quienes tú invites.
- **Servicio de Correo Personalizado**: Incluimos un servicio de correo (`mail-service`) basado en Node.js que resuelve las incompatibilidades de autenticación y asegura que las invitaciones llegen siempre a su destino.
- **Arquitectura Moderna**: Soporte nativo para CockroachDB, Redpanda, MinIO y Elasticsearch.
- **Optimizado para Dokploy**: Integración automática con Traefik y gestión de volúmenes.

## 🚀 Requisitos de Hardware

Para un funcionamiento fluido de todos los servicios:
* **RAM**: Mínimo **4GB** (Recomendado 8GB para producción).
* **CPU**: 2 Cores o más.
* **Almacenamiento**: SSD recomendado.

## 🛠️ Guía de Instalación en Dokploy

### 1. Preparación del Servidor
Es **CRÍTICO** aumentar el límite de mapas de memoria para Elasticsearch. Ejecuta en tu servidor host:
```bash
sudo sysctl -w vm.max_map_count=262144
```
*(Hazlo persistente editando `/etc/sysctl.conf`)*.

### 2. Configuración en Dokploy
1.  Crea un nuevo proyecto y selecciona el tipo **"Compose"**.
2.  **Docker Compose**: Copia el contenido de nuestro [`docker-compose.yml`](./docker-compose.yml).
3.  **Variables de Entorno**: Usa como base nuestro [`.env.example`](./.env.example). Asegúrate de configurar:
    - `HOST_ADDRESS`: Tu dominio (ej. `huly.tusitio.com`).
    - `SMTP_*`: Tus credenciales de Yandex o cualquier proveedor SMTP.
    - `SECRET`: Una cadena aleatoria y segura.

## 🆘 ¿Necesitas Ayuda?

Si encuentras problemas técnicos durante el despliegue:
*   **Comunidad Huly**: [Discord oficial de Huly](https://huly.io/discord)
*   **Documentación Oficial**: [Huly Docs](https://docs.huly.io)
*   **Soporte Técnico Especializado**: Si necesitas un despliegue profesional, soporte directo o consultoría en infraestructura, visita **[se2code.com](https://www.se2code.com)**.

## 📂 Estructura del Proyecto
- `mail-service/`: Código fuente de nuestro servicio de correo personalizado.
- `docker-compose.yml`: Definición principal del stack.
- `.env.example`: Plantilla de variables de entorno.

---
Hecho con ❤️ por el equipo de **[se2code.com](https://www.se2code.com)**.
