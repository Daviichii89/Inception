# USER_DOC

## Provided Services
This stack provides:
- `nginx`: HTTPS web entrypoint on port `443`.
- `wordpress`: WordPress application served through php-fpm.
- `mariadb`: database backend for WordPress.

## Start And Stop
Start services:
```bash
make
```
or
```bash
make up
```

Stop services:
```bash
make down
```

Remove everything (containers, images, volumes):
```bash
make fclean
```

## Website And Admin Access
Open:
- `https://<your_login>.42.fr`

WordPress admin panel:
- `https://<your_login>.42.fr/wp-admin`

## Credentials Location And Management
Credentials are stored as Docker secret files under `secrets/` and loaded at runtime.

Relevant files:
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_user_password.txt`
- `secrets/wp_root_password.txt`

To rotate a credential:
1. Update the relevant file in `secrets/`.
2. Recreate services with `make re`.

## Service Health Checks
List running containers:
```bash
cd srcs && docker compose ps
```

View logs:
```bash
cd srcs && docker compose logs -f
```

Check HTTPS endpoint:
```bash
curl -kI https://<your_login>.42.fr
```
