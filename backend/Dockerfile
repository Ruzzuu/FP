# Build stage
FROM node:20-slim AS builder

WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma/

# Add npm config for faster install
RUN npm config set fetch-timeout 60000 && \
    npm config set fetch-retries 5 && \
    npm ci

RUN npx prisma generate

COPY . .

RUN npm run build

# Production stage
FROM node:20-slim AS production

RUN apt-get update -y && \
    apt-get install -y openssl wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

RUN mkdir -p /app/uploads /app/database

EXPOSE 5000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/src/main.js"]
