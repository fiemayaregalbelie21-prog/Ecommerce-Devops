# E-Commerce App — DevOps Setup

This repo contains the DevOps wrapper around the Flutter e-commerce app (built against
[FakeStoreAPI](https://fakestoreapi.com)), plus a small companion Node.js/Postgres
backend added specifically to satisfy the assignment's multi-container requirement.

## Why there's a backend at all

FakeStoreAPI is the app's real data source for products, categories, and users — it's an
external, hosted, read-mostly API and isn't something you host or containerize yourself.
The assignment's Step 4, however, requires a database service that the app connects to
by service name. To do that honestly (not just adding an unused Postgres container), this
backend handles two small pieces of *your own* app data that FakeStoreAPI doesn't provide:

- **Order history** — a persistent record of checkout events, so a user's past orders
  survive app reinstall or a new device (FakeStoreAPI's own `/carts` endpoint is a demo
  stub and doesn't persist real writes).
- **Wishlist sync** — mirrors the locally-persisted (Hive) wishlist server-side so it can
  be restored on login from a different device.

## Project layout

```
.
├── backend/                  # Node.js/Express API, backed by Postgres
│   ├── src/
│   │   ├── index.js           # app entrypoint
│   │   ├── routes/            # health, orders, wishlist
│   │   ├── controllers/       # request handlers / DB queries
│   │   ├── db/pool.js         # pg connection pool + startup retry logic
│   │   └── middleware/        # central error handling
│   ├── db-init/001_init.sql   # schema, auto-applied on first Postgres boot
│   ├── test/                  # API tests (Node's built-in test runner + supertest)
│   ├── Dockerfile
│   └── .dockerignore
├── frontend/                  # Flutter web build → served by nginx
│   ├── Dockerfile              # multi-stage: flutter build → nginx runtime
│   ├── nginx.conf
│   └── .dockerignore
│   (drop your existing Flutter project's files into this folder — see below)
├── docker-compose.yml         # db + backend + frontend, wired together
└── .github/workflows/ci-cd.yml
```

## Wiring your existing Flutter project in

Your `lib/` project (per your own README — Clean Architecture with Riverpod, Dio, Hive)
goes into `frontend/`, alongside the `Dockerfile`, `nginx.conf`, and `.dockerignore`
already there. Concretely: copy `pubspec.yaml`, `pubspec.lock`, `lib/`, and any other
Flutter project files into `frontend/` so that `frontend/pubspec.yaml` and
`frontend/lib/` exist. No app code changes are required — the backend is additive and
doesn't replace any FakeStoreAPI calls you already have.

If you want the app to actually call the new endpoints (optional, but strengthens your
submission), add a small `OrderHistoryRepository`/`WishlistSyncRepository` in your `data`
layer that hits:

- `POST http://localhost:4000/api/orders` — `{ userId, items, total }`
- `GET  http://localhost:4000/api/orders/:userId`
- `GET  http://localhost:4000/api/wishlist/:userId`
- `POST http://localhost:4000/api/wishlist/:userId` — `{ productId }`
- `DELETE http://localhost:4000/api/wishlist/:userId/:productId`

## Mapping to the assignment steps

| Step | Where |
|---|---|
| 1. Dockerfile with best practices | `backend/Dockerfile` (multi-stage, slim base, layer-cached deps, non-root user, HEALTHCHECK) and `frontend/Dockerfile` (same pattern for the Flutter web build) |
| 2. Build & run locally | See commands below |
| 3. `.dockerignore` + image size comparison | `backend/.dockerignore`, `frontend/.dockerignore` — comparison steps below |
| 4. Multi-container with Compose | `docker-compose.yml` — `backend` connects to `db` using the hostname `db` (the Compose service name) |
| 5. Publish to registry | `publish` job in `.github/workflows/ci-cd.yml`, or manual steps below |
| 6. GitHub Actions CI/CD (bonus) | `.github/workflows/ci-cd.yml` — runs backend tests against a real Postgres service container on every push, then validates the Docker build |

## Running locally

### Whole stack via Compose (recommended)
```bash
docker compose up --build
```
- Frontend (Flutter web): http://localhost:3000
- Backend API: http://localhost:4000/health
- Postgres: localhost:5432 (user/pass: postgres/postgres, db: ecommerce)

### Backend alone, manually (Step 2 of the assignment)
```bash
cd backend
docker build -t yourname/ecommerce-backend:1.0 .
docker run -d -p 4000:4000 \
  -e DB_HOST=host.docker.internal \
  -e DB_USER=postgres -e DB_PASSWORD=postgres -e DB_NAME=ecommerce \
  yourname/ecommerce-backend:1.0
```

## Image size comparison (Step 3)

To reproduce the before/after `.dockerignore` comparison for your submission:
```bash
# With .dockerignore in place (current state)
docker build -t backend:with-ignore ./backend
docker images backend:with-ignore

# Temporarily rename .dockerignore, rebuild, compare
mv backend/.dockerignore backend/.dockerignore.bak
docker build -t backend:without-ignore ./backend
docker images backend:without-ignore
mv backend/.dockerignore.bak backend/.dockerignore
```
Record both sizes in your submission — excluding `node_modules`/`.git` from the build
context keeps the image smaller and the build faster, since Docker doesn't need to hash
and send those files to the daemon.

## Publishing to Docker Hub (Step 5)

Manual:
```bash
docker login
docker tag ecommerce-backend:ci yourname/ecommerce-backend:1.0
docker push yourname/ecommerce-backend:1.0
```
Automated: push to `main` with `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` set as repo
secrets, and the `publish` job in the CI/CD workflow does this for you.

## CI/CD pipeline (Step 6)

On every push/PR, `.github/workflows/ci-cd.yml`:
1. Spins up a real Postgres service container.
2. Installs backend deps and applies the schema.
3. Runs the test suite (`npm test`) against that real database.
4. Validates the backend Docker image builds successfully.
5. On pushes to `main` only, builds and publishes the backend image to Docker Hub.
