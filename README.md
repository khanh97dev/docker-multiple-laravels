# 🚀 Docker Multi-Laravel Project

Automate deployment and development of multiple independent Laravel applications within a single Docker environment, supporting application separation by domain (e.g. `web1.com`, `web2.com`).

✅ **Key Features:**
- Run **multiple Laravel apps** in one Docker setup.
- Use **Nginx as reverse proxy**, routing requests by domain.
- Resource-efficient: share PHP-FPM and database containers (easily extendable).
- Simple to scale — add new apps just by creating a new source folder.
- Auto-configure Nginx via `default.conf`.
- Customize `docker-entrypoint.sh` for app initialization (composer install, migrate, seed, etc.).

## 📁 Project Structure
```
.
├── Dockerfile               # PHP-FPM Dockerfile (shared dependencies)
├── docker-compose.yml       # Manages services: php-fpm, nginx, mysql (optional)
├── docker-entrypoint.sh     # Startup script for PHP container
├── nginx/
│   ├── Dockerfile           # Dedicated Nginx Dockerfile
│   ├── conf.d/
│   │   └── default.conf     # Multi-site Nginx config (domain-based routing)
│   └── docker-entrypoint.sh # Nginx startup script
└── sources/
    ├── web1.com/            # Laravel App 1
    │   ├── artisan          # Artisan CLI
    │   └── public/
    │       └── index.php
    └── web2.com/            # Laravel App 2
        ├── artisan
        └── public/
            └── index.php
```

## 🛠️ How to Use

1. **Install Docker & Docker Compose**  
   Ensure you have [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed.

2. **Build and start containers**
`bash
docker-compose up -d --build
`

3. **Add domains to `/etc/hosts`** (required for local domain resolution)
`text
127.0.0.1 web1.com
127.0.0.1 web2.com
`

4. **Access your apps**
- `http://web1.com` → Laravel App 1
- `http://web2.com` → Laravel App 2

> ✅ Note: Ensure `composer install` is run inside each app directory before building, or automate it via `docker-entrypoint.sh`.

## 🔧 Customization

- Change Nginx port in `docker-compose.yml` if needed.
- Add MySQL/PostgreSQL to `docker-compose.yml` if required.
- Modify `default.conf` to enable HTTPS (Let’s Encrypt), caching, or security rules.

## 📌 Suggested Extensions

- Replace Nginx with **Traefik** for automatic HTTPS (Let’s Encrypt).
- Integrate **Redis** or **Queues** per app.
- Create a script to auto-generate new app folders.

## 📝 Notes

- All Laravel apps must follow standard structure (`public/index.php`, `artisan`, `config`, etc.).
- If you need to run `php artisan migrate`, ensure it's triggered in `docker-entrypoint.sh` after `composer install`.

---

## 🤝 Contact

- **Nickname:** Kai  
- **Interests:** Web development, UI design, database optimization, software architecture  

> 💡 Ideal for developers who want to test multiple Laravel apps locally, or build a simple multi-tenant system.

---

📌 Star (⭐) this repo if you find it helpful!
