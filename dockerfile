# Etapa 1: Build app
FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Etapa 2: Imagen final con PHP, Node y Coolify
FROM php:8.1-fpm-alpine
# Instala dependencias del sistema
RUN apk add --no-cache \
    nodejs npm \
    bash git openssh

WORKDIR /coolify
COPY --from=builder /app ./

# Instala paquetes PHP
RUN apk add --no-cache icu-dev \
    && docker-php-ext-install intl pdo pdo_mysql

RUN composer install --no-dev --optimize-autoloader

# Genera assets o scripts de Node si es que hace falta
RUN npm install && npm run build

EXPOSE 8080
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
