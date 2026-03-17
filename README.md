*This project has been created as part of the 42 curriculum by davifer2.*

## Description
Inception is a system administration project focused on containerized infrastructure with Docker Compose.

The stack includes three isolated services:
- NGINX as the single public entrypoint on port 443 with TLSv1.2/TLSv1.3.
- WordPress with php-fpm (without NGINX inside the container).
- MariaDB as the database service.

The goal is to build each service from custom Dockerfiles, connect them through a dedicated Docker network, and persist application data with Docker volumes.

### Docker Use And Project Sources
Docker is used to package each service with explicit dependencies and reproducible startup behavior.

Project sources are organized under `srcs/`:
- `srcs/docker-compose.yml`: service orchestration, network, volumes, and secrets.
- `srcs/.env`: non-sensitive environment configuration.
- `srcs/requirements/<service>/`: Dockerfiles and service-specific configuration/entrypoint scripts.
- `secrets/`: local secret files consumed with Docker secrets (git-ignored).

### Main Design Choices
- One process per container and one container per service.
- No prebuilt service images from Docker Hub beyond the base OS image.
- Startup logic in entrypoint scripts for deterministic initialization.
- Named volumes for persistent WordPress and MariaDB data.
- Internal bridge network for private service-to-service communication.

### Comparisons
#### Virtual Machines vs Docker
- Virtual machines emulate full operating systems with heavier resource usage.
- Docker containers share the host kernel and start faster with lower overhead.
- VMs are better for strong OS-level isolation; containers are better for lightweight service deployment.

#### Secrets vs Environment Variables
- Environment variables are practical for non-sensitive config.
- Secrets are better for confidential values (passwords/keys) because they are mounted as files at runtime and kept out of the image layers.

#### Docker Network vs Host Network
- Docker bridge networks isolate container communication and provide built-in DNS by service name.
- Host network removes isolation and can create port conflicts.
- This project uses a dedicated Docker bridge network to keep the stack private and explicit.

#### Docker Volumes vs Bind Mounts
- Docker volumes are managed by Docker and are portable across host directory changes.
- Bind mounts directly map host paths and couple runtime behavior to host filesystem layout.
- This project uses named Docker volumes for service data persistence.

## Instructions
### Prerequisites
- Docker Engine
- Docker Compose plugin (`docker compose`)
- Secret files present under `secrets/`

### Build And Run
```bash
make
```
or
```bash
make up
```

### Stop
```bash
make down
```

### Full Cleanup
```bash
make fclean
```

## Resources
- Docker Docs: https://docs.docker.com/
- Docker Compose Specification: https://compose-spec.io/
- NGINX Docs: https://nginx.org/en/docs/
- PHP-FPM Docs: https://www.php.net/manual/en/install.fpm.php
- MariaDB Docs: https://mariadb.com/kb/en/documentation/
- WordPress CLI Docs: https://developer.wordpress.org/cli/commands/

### AI Usage In This Project
AI was used for:
- Reviewing configuration consistency across Dockerfiles, Compose, and entrypoint scripts.
- Generating a compliance checklist against the project subject.
- Drafting and refining technical documentation structure.

AI was not used as an unchecked copy-paste source for core project logic. All generated content was reviewed and adjusted manually.
