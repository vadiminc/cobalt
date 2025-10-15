FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache python3 alpine-sdk

RUN pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

# Enable corepack for pnpm (Railway might need it)
RUN corepack enable

COPY --from=build --chown=node:node /prod/api /app

# Install git and create minimal git repo for version-info package
RUN apk add --no-cache git && \
    cd /app && \
    git init && \
    git config user.email "docker@cobalt" && \
    git config user.name "Docker Build" && \
    git remote add origin https://github.com/imputnet/cobalt.git && \
    git add -A && \
    git commit -m "docker build" || true && \
    chown -R node:node /app/.git

# Create cookies.json with proper permissions
RUN touch /app/cookies.json && chown node:node /app/cookies.json

USER node

EXPOSE 9000
# CMD [ "node", "src/cobalt" ]
CMD sh -c 'echo "$ALL_COOKIES" > /app/cookies.json && node src/cobalt'
