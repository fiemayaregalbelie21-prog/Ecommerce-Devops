# Ecommerce DevOps Architecture & Setup

This repository contains the containerization and DevOps infrastructure I built for my Flutter e-commerce web application. The core frontend interacts with the external FakeStoreAPI for general catalog and user data, while a custom Node.js/Postgres backend microservice handles persistent user state and database integration.

**Repository:** https://github.com/fiemayaregalbelie21-prog/Ecommerce-Devops
**Live Docker Hub image:** https://hub.docker.com/repository/docker/fiemayaregalbelie21/ecommerce-backend

---

## Technical Overview & Architecture

While FakeStoreAPI provides read-mostly product listings, it lacks persistent state for transactional user actions. To meet full multi-container specifications and handle app-specific data, I designed a dedicated companion backend service:

* **Persistent Order History:** Records checkout events directly to a PostgreSQL instance so user order records persist across sessions.
* **Wishlist Synchronization:** Mirrors local Hive cache data server-side to allow wishlist retrieval across different client environments.
* **Frontend Service:** Multi-stage Flutter web container served over Nginx.

---

## Project Structure

```text
.
├── backend/                  # Express.js REST API with PostgreSQL driver
│   ├── src/
│   │   ├── index.js          # Service entry point
│   │   ├── routes/           # Health, order, and wishlist routing
│   │   ├── controllers/      # Database interaction logic
│   │   ├── db/pool.js        # Connection pooling and startup retries
│   │   └── middleware/       # Centralized error handling
│   ├── db-init/001_init.sql  # Database schema auto-initialization script
│   ├── test/                 # Integration test suite (Node test runner + Supertest)
│   ├── Dockerfile            # Optimized multi-stage build configuration
│   └── .dockerignore
├── frontend/                 # Flutter web source and server setup
│   ├── Dockerfile            # Multi-stage build (Flutter SDK -> Nginx runtime)
│   ├── nginx.conf            # Custom routing configuration
│   └── .dockerignore
├── docker-compose.yml        # Multi-container orchestration logic
└── .github/workflows/ci-cd.yml # Automated CI/CD pipeline
```

## API Endpoints

The primary API routes exposed by the Node.js backend include:

- `GET /health` — Service health check endpoint
- `POST /api/orders` — Record checkout payload `{ userId, items, total }`
- `GET /api/orders/:userId` — Retrieve order history by user ID
- `GET /api/wishlist/:userId` — Fetch active server-synced wishlist
- `POST /api/wishlist/:userId` — Sync item to wishlist `{ productId }`
- `DELETE /api/wishlist/:userId/:productId` — Remove item from wishlist

## Local Development & Container Execution

### Orchestrated Stack (Docker Compose)

To spin up all services simultaneously (Database, API, and Frontend):

```bash
docker compose up --build
```

Service Routing:
- Frontend Interface: http://localhost:3000
- Backend API: http://localhost:4000/health
- Postgres Instance: localhost:5432 (user: postgres, password: postgres, db: ecommerce)

### Backend Isolated Run

To run and test the backend service independently:

```bash
cd backend
docker build -t fiemayaregalbelie21/ecommerce-backend:1.0 .
docker run -d -p 4000:4000 \
  -e DB_HOST=host.docker.internal \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_NAME=ecommerce \
  fiemayaregalbelie21/ecommerce-backend:1.0
```

## Optimization & Build Context

Both services use multi-stage builds and `.dockerignore` rules to keep the Docker build context clean (excluding `node_modules`, `.git`, and other local-only files). In testing, the built image sizes were identical with and without `.dockerignore` (200MB) — since the Dockerfile's `COPY` instructions only pull in `package.json` and `src/` explicitly, there was no local `node_modules` present to accidentally include. The exclusions still matter for build context hygiene and avoiding accidental secret leakage in workflows where dependencies are installed locally before building.

To inspect the image footprint yourself:

```bash
# Optimized build context
docker build -t backend:optimized ./backend
docker images backend:optimized

# Unoptimized build context test
mv backend/.dockerignore backend/.dockerignore.bak
docker build -t backend:unoptimized ./backend
docker images backend:unoptimized
mv backend/.dockerignore.bak backend/.dockerignore
```

## Continuous Integration & Deployment (CI/CD)

The repository uses GitHub Actions (`.github/workflows/ci-cd.yml`) to enforce build reliability:

- **Test Environment:** Provisions an ephemeral PostgreSQL service container on push or pull request.
- **Database Verification:** Applies migration scripts (`001_init.sql`) and runs `npm test`.
- **Container Validation:** Verifies multi-stage Docker builds complete without errors.
- **Registry Push:** On merges to `main`, automatically builds and publishes tagged images to Docker Hub (`fiemayaregalbelie21/ecommerce-backend`).