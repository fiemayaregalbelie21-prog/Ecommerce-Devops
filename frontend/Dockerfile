# --- Build stage: compiles the Flutter app to static web assets ---
# NOTE: Drop your actual Flutter project (the "lib/", "pubspec.yaml", etc.
# described in your README) into this "frontend/" folder before building,
# or adjust the build context in docker-compose.yml to point at your
# existing project root instead.
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Copy only the dependency manifest first so `flutter pub get` is cached
# and doesn't re-run on every source change (same layering principle as
# the backend's package.json copy).
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Now copy the rest of the source and build.
COPY . .
RUN flutter build web --release

# --- Runtime stage: minimal static file server ---
FROM nginx:1.27-alpine AS runtime
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
