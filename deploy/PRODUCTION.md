# SmartGPS Lightsail deployment

This deployment keeps PostgreSQL and Redis private inside Docker. Only Caddy
publishes ports 80 and 443. Use an Ubuntu 24.04 Lightsail instance with a
static IPv4 address and open inbound TCP ports 80, 443, and 22 (SSH).

## DNS and secrets

Create a DNS A record for the chosen hostname pointing to the Lightsail static
IPv4 address. Wait until public DNS resolves to that address before starting
Caddy so it can issue and renew the public HTTPS certificate automatically.

Copy `.env.production.example` to `.env.production`, set `DOMAIN` and
`PUBLIC_ORIGIN` to the same `https://` hostname, and replace every secret with
independent random values. Keep `.env.production` private and do not commit it.

## First startup

1. Run `docker compose --env-file .env.production -f docker-compose.production.yml up -d --build`.
2. On the first startup only, `DB_SCHEMA_SYNC=true` creates the initial schema
   from the TypeORM entities. Wait for the API health check to pass.
3. Set `DB_SCHEMA_SYNC=false` in `.env.production`, then recreate only the API:
   `docker compose --env-file .env.production -f docker-compose.production.yml up -d --force-recreate backend`.
4. The admin bootstrap runs only when `BOOTSTRAP_ADMIN=true`; after confirming
   the admin account works, set it to `false` and remove `ADMIN_PASSWORD` from
   `.env.production`.
5. Check `https://<your-hostname>/health` and configure the APK API Server as
   `https://<your-hostname>`.

The included SQL migration files are incomplete and are not used for this first
deployment. Do not enable schema synchronization after initialization. Before
future releases that change database entities, add and review complete database
migrations and take a database backup.

## Backups

The PostgreSQL volume is persistent across container restarts, but it is not a
backup. Schedule encrypted `pg_dump` backups and copy them off the instance;
verify that a backup can be restored before relying on it.
