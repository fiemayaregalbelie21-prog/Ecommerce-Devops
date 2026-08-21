# --- Base stage: shared setup for install & runtime ---
FROM node:20-alpine AS base
WORKDIR /app

# --- Dependencies stage: cached separately from source code ---
# Copying only package*.json first means Docker only re-runs npm install
# when dependencies actually change, not on every source code edit.
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm install --omit=dev

# --- Runtime stage: minimal final image ---
FROM base AS runtime
ENV NODE_ENV=production

# Run as a non-root user for security (alpine's node image ships a "node" user).
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

USER node

EXPOSE 4000

# Basic container-level health check hitting our /health endpoint.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:4000/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "src/index.js"]
