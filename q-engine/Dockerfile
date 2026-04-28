# syntax=docker/dockerfile:1.6
# ---------------------------------------------------------------------------
# Multi-stage build for the q-engine NestJS API.
#   Stage 1 (deps):   install all deps so Nest CLI can build.
#   Stage 2 (build):  produce dist/.
#   Stage 3 (runner): tiny final image with only prod deps.
# ---------------------------------------------------------------------------

FROM node:22-bookworm-slim AS deps
WORKDIR /app

# Native add-ons: pdf-parse + huggingface transformers + node-llama-cpp need
# build tools and python on first install.
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --no-audit --no-fund

# ---------------------------------------------------------------------------
FROM deps AS build
WORKDIR /app
COPY . .
RUN npm run build

# Trim dev deps for the final image.
RUN npm prune --omit=dev

# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS runner
WORKDIR /app

# Tini = clean PID 1 so SIGTERM propagates and zombies get reaped.
# curl is used by the Docker HEALTHCHECK below.
RUN apt-get update && apt-get install -y --no-install-recommends \
      tini curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Run as non-root.
RUN useradd --system --create-home --uid 1001 nodeapp

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=build --chown=nodeapp:nodeapp /app/node_modules ./node_modules
COPY --from=build --chown=nodeapp:nodeapp /app/dist ./dist
COPY --from=build --chown=nodeapp:nodeapp /app/package.json ./package.json

# Persistent storage mount points; declared so anonymous volumes don't form.
RUN mkdir -p /app/uploads && chown nodeapp:nodeapp /app/uploads
VOLUME ["/app/uploads"]

USER nodeapp

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT}/health || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "dist/main.js"]
