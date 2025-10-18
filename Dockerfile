FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN apk add --no-cache python3 alpine-sdk
RUN corepack enable

# pnpm will be auto-installed from package.json on first use
RUN pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app

# Copy cookies.json from build context
COPY --chown=node:node api/cookies.json /app/cookies.json

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

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
