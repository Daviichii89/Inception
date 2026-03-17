# DEV_DOC

## Environment Setup From Scratch
### Prerequisites
- Linux environment (project VM)
- Docker Engine
- Docker Compose plugin
- `make`

### Required Configuration
1. Create/update `srcs/.env` with stack variables (domain, DB names/users, WordPress metadata).
2. Create secret files under `secrets/`:
   - `db_password.txt`
   - `db_root_password.txt`
   - `wp_user_password.txt`
   - `wp_root_password.txt`
3. Ensure your local DNS/hosts points `<login>.42.fr` to your machine IP when needed for validation.

## Build And Launch
From repository root:
```bash
make up
```

This executes `docker compose up -d --build` in `srcs/`.

## Container And Volume Management Commands
Start/stop stack:
```bash
make up
make down
```

Rebuild cleanly:
```bash
make re
```

Inspect state:
```bash
cd srcs && docker compose ps
cd srcs && docker compose logs -f
```

Inspect volumes:
```bash
docker volume ls
docker volume inspect mariadb_data
docker volume inspect wp_data
```

## Data Storage And Persistence
Persistent data uses named Docker volumes:
- `mariadb_data` mounted at `/var/lib/mysql` in the MariaDB container.
- `wp_data` mounted at `/var/www/html` in the WordPress container.

Because these are named volumes, data persists across container recreation (`make down`) and is removed only when volumes are explicitly deleted (for example with `make fclean`).
