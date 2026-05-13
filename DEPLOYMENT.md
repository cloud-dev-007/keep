# qCraft — Deployment Guide

Step-by-step instructions for running qCraft locally for development, in
Docker for testing, and on a Linux VPS for live use.

---

## 0. Architecture at a glance

```
+-------------+        HTTPS        +-----------------+
| Flutter app |  ---------------->  | Caddy (TLS)     |
+-------------+                     +--------+--------+
                                             | reverse_proxy
                                             v
                                    +--------+--------+
                                    | q-engine (API)  |  NestJS
                                    +--------+--------+
                                             |
                       +---------------------+----------------------+
                       v                                            v
              +--------+---------+                         +--------+--------+
              | Postgres +       |                         | Ollama (LLM,    |
              | pgvector         |                         | OpenAI-compat)  |
              +------------------+                         +-----------------+
```

In **dev** the Flutter app talks to `http://localhost:3000`, the API runs on
your host (`npm run start:dev`), Postgres runs in Docker, and the LLM is
served by **LM Studio** on the same machine.

In **prod** everything except the Flutter app runs in Docker on a single VPS.
Caddy terminates TLS, the API talks to Ollama and Postgres over the internal
docker network, and the Flutter app is built with `--dart-define` pointing
at the public domain.

---

## 1. Prerequisites

### 1.1 For local development

| Tool | Version | Notes |
|---|---|---|
| Node.js | 22.x | Use [nvm](https://github.com/nvm-sh/nvm) |
| npm | 10.x | Ships with Node 22 |
| Docker + Docker Compose | latest | For the database |
| LM Studio | latest | [https://lmstudio.ai](https://lmstudio.ai). Load any chat model and start the local server (default port `1234`) |
| Flutter | 3.6.1 | For the mobile app (optional) |
| Git | any | |

### 1.2 For VPS deployment

- A Linux VPS — Ubuntu 22.04+ recommended.
- Minimum **4 vCPU / 8 GB RAM / 40 GB disk** (Ollama with `llama3.1:8b` needs ~6 GB RAM by itself; bigger models need more). For a CPU-only box, a smaller model like `llama3.2:3b` runs faster.
- A domain name pointing at the VPS IP (A record).
- Open ports `80` and `443` in the firewall.
- Docker + Docker Compose installed:
  ```bash
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER && newgrp docker
  ```

---

## 2. Local developmen

This is the workflow you'll use day-to-day.

### 2.1 Start the database

```bash
cd q-engine
docker compose up -d
```

That brings up Postgres (with the pgvector extension) on `localhost:5432`.

### 2.2 Start LM Studio

1. Open LM Studio.
2. Download any chat-tuned model (e.g. `llama-3.1-8b-instruct`).
3. Click **Local Server** → **Start Server**. Confirm it's listening on `http://localhost:1234`.

### 2.3 Configure env

```bash
cd q-engine
cp .env.example .env       # if you don't already have one
```

For first-time setup, you may want `DB_SYNCHRONIZE=true` so the schema is created automatically — flip it back to `false` after the first boot, then rely on migrations.

Or just run migrations once:

```bash
npm install
npm run migration:run
```

### 2.4 Run the API

```bash
npm install
npm run start:dev
```

You should see:

```
LLM configured: baseURL=http://localhost:1234/v1, model=(server default), timeout=120000ms
q-engine running on http://0.0.0.0:3000
Swagger UI:    http://0.0.0.0:3000/api/docs
Health check:  http://0.0.0.0:3000/health
(don't close this terminal window while working on the project or doing flutter run)
```

Open `http://localhost:3000/api/docs` for the interactive Swagger UI. Open `http://localhost:3000/health` to confirm the DB and LLM are reachable.

### 2.5 Run the Flutter app
(make sure the backend is running and flutter is installed and configured)

```bash
cd ../qcraft

flutter pub get
# Generated retrofit/json files — only needed the first time:
dart run build_runner build --delete-conflicting-outputs

# iOS simulator / connected Android device:
flutter run

# Android emulator: localhost on the host is 10.0.2.2 inside the emulator.
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/
```

### 2.6 Tests

```bash
cd q-engine
npm test                # unit tests
npm run test:e2e        # quiz HTTP e2e (no DB/LLM required)
npm run test:cov        # with coverage
```

### 2.7 Common dev commands

```bash
# Generate a new migration after editing entities:
npm run migration:generate -- src/migrations/AddSomething

# Apply pending migrations:
npm run migration:run

# Rollback the most recent migration:
npm run migration:revert

# Format / lint:
npm run format
npm run lint
```

---

<!-- ## 3. Local end-to-end Docker run (optional)

If you want to test the **production stack** on your own machine before deploying — same containers, same networking, just no public domain:

```bash
cd q-engine
cp .env.production.example .env.production
 
# Edit .env.production. For local testing, use:
#   DOMAIN=localhost
#   LETSENCRYPT_EMAIL=you@example.com   (won't be used)
# And remove the caddy service if you want to bypass TLS, or replace
# the Caddyfile with `:80 { reverse_proxy api:3000 }`.

docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build

# Pull the LLM model the first time (one-off):
docker compose -f docker-compose.prod.yml exec ollama ollama pull llama3.1:8b
```

Then hit `http://localhost/health`. Tear down with:

```bash
docker compose -f docker-compose.prod.yml down
```

(Use `down -v` to also drop the data volumes.) -->

---

## 4. Live VPS deployment

### 4.1 Point your domain at the VPS

Create an `A` record:

```
your-domain.com → <VPS public IP>
```

Wait for it to propagate (`dig your-domain.com` should return the VPS IP).

### 4.2 SSH into the VPS and clone the repo

```bash
# scp command to copy the codebase to the vps
scp -r /path/to/local/codebase user@your-vps-ip:/path/to/remote/codebase
# after ssh into ur vps , copy the codebase to the vps or clone using git if you have already pushed it to a remote repo , i advise using scp
```

### 4.3 Configure production env

```bash
cp .env.production.example .env.production
nano .env.production
```

Set:

```
DOMAIN=your-domain.com
LETSENCRYPT_EMAIL=you@your-domain.com
DB_PASSWORD=<generate a long random password>
CORS_ORIGINS=https://your-domain.com
LLM_MODEL=llama3.1:8b      # or llama3.2:3b on smaller VPSes
```

Generate a strong password with: 

```bash
openssl rand -base64 32
```

### 4.4 Build and start the stack

```bash
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

Check status:

```bash
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs -f api
```

### 4.5 Pull the Ollama model (one-off)

The Ollama container starts empty. Pull whichever model you set as `LLM_MODEL`:

```bash
docker compose -f docker-compose.prod.yml exec ollama ollama pull llama3.1:8b
```

This downloads ~5 GB; takes a few minutes. The API container's healthcheck will start passing once the model is loadable.

### 4.6 Verify

```bash
curl -fsS https://your-domain.com/health
curl -fsS https://your-domain.com/api/docs   # Swagger UI in browser
```

Caddy will fetch a Let's Encrypt cert automatically on first request. 

### 4.7 Build and ship the Flutter app

From your dev machine:

```bash
cd qcraft

# Android:
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-domain.com/

# iOS:
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://your-domain.com/
```

The resulting `.apk` / `.ipa` lives in `build/app/outputs/`.

---

## 5. Operations

### 5.1 Logs

```bash
docker compose -f docker-compose.prod.yml logs -f api
docker compose -f docker-compose.prod.yml logs -f ollama
docker compose -f docker-compose.prod.yml logs -f caddy
```

### 5.2 Updating after a code change

```bash
git pull
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build api
```

`migrationsRun: true` is on, so any new migrations apply on boot.

### 5.3 Database backups

```bash
# One-shot backup
docker compose -f docker-compose.prod.yml exec -T db \
  pg_dump -U $DB_USER $DB_NAME | gzip > "backup-$(date +%F).sql.gz"

# Restore
gunzip -c backup-2026-04-26.sql.gz | \
  docker compose -f docker-compose.prod.yml exec -T db psql -U $DB_USER -d $DB_NAME
```

For automated backups, add a cron job that uploads the dump to S3/R2/Backblaze.

### 5.4 Swapping the LLM model

```bash
docker compose -f docker-compose.prod.yml exec ollama ollama pull llama3.2:3b
# Then update LLM_MODEL in .env.production and:
docker compose -f docker-compose.prod.yml --env-file .env.production up -d api
```

### 5.5 Switching to a hosted LLM API

If you'd rather not run your own LLM, point at OpenAI (or any compatible provider) by overriding three env vars in `.env.production`:

```
LLM_BASE_URL=https://api.openai.com/v1
LLM_API_KEY=sk-...
LLM_MODEL=gpt-4o-mini
```

Then remove the `ollama` service from `docker-compose.prod.yml` (or leave it idle), restart the API.

---

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| API logs `LLM backend unavailable` | LM Studio / Ollama not running | Start the local server, or `docker compose ... up -d ollama` |
| API logs `database "qcraft" does not exist` | DB env mismatch | Make sure `DB_NAME` matches what Postgres created on first boot |
| `migrationsRun: true` but nothing happens | Migrations were already applied | Check `q_engine_migrations` table |
| Caddy 502s | API container unhealthy | `docker compose ... logs api` and look for the actual stack trace |
| `Unable to parse "..." as a boolean` | LLM returned an unexpected verdict | The service now defaults to "incorrect" instead of crashing — check logs for the offending question |
| Healthcheck fails on Ollama for ~60s after boot | Cold start | Normal — `start_period` is 60s. Wait. |
| Flutter app times out hitting localhost on Android emulator | Emulator can't see host's localhost | Use `--dart-define=API_BASE_URL=http://10.0.2.2:3000/` |
| Question generation returns empty | LLM hit timeout / empty response | Increase `LLM_TIMEOUT_MS`; try a stronger model |

---

## 7. Environment reference

See `q-engine/.env.example` and `q-engine/.env.production.example` for the
complete list of variables. Critical ones:

| Var | Dev default | Prod recommendation |
|---|---|---|
| `NODE_ENV` | `development` | `production` |
| `DB_HOST` | `localhost` | `db` (the docker service name) |
| `DB_SYNCHRONIZE` | `false` | `false` (always) |
| `DB_MIGRATIONS_RUN` | `true` | `true` |
| `LLM_BASE_URL` | `http://localhost:1234/v1` | `http://ollama:11434/v1` |
| `LLM_MODEL` | _(blank — LM Studio default)_ | `llama3.1:8b` |
| `CORS_ORIGINS` | `*` | `https://your-domain.com` |
| `THROTTLE_LIMIT` | `120` | tighten if abused |
| `MAX_UPLOAD_MB` | `25` | match Caddy's `request_body max_size` |

---

## 8. What's NOT included (yet)

This deployment is intentionally simple. Things you'd want to add before
serving real users:

- **Authentication.** All endpoints are open. Add JWT + a User entity if the API ever leaves a private network.
- **Rate-limiting per user, not just per IP.** Easy once you have auth.
- **CI/CD.** `.github/workflows/` is missing; add a workflow that runs `npm test` + `docker build` on every push.
- **Object storage.** Uploads currently live in a docker volume — fine for one VPS, not great if you ever scale out. Move to S3-compatible storage when needed.
- **Observability.** Add Prometheus + Grafana for metrics, or pipe logs to Loki / a hosted log service.
