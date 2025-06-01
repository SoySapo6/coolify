# Etapa 1: Build
FROM node:20 AS builder

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala dependencias (dev y prod)
RUN npm install

# Copia todo el proyecto
COPY . .

# Construye la app
RUN npm run build

# Etapa 2: Producción
FROM node:20 AS runner

WORKDIR /app

# Instala solo dependencias de producción (en este caso no hay muchas, pero por si acaso)
COPY package*.json ./
RUN npm install --omit=dev

# Copia la build generada
COPY --from=builder /app/dist /app/dist

# Instala 'serve' para servir estáticos (puedes cambiarlo si usas otro server)
RUN npm install -g serve

# Exponemos el puerto que usará el server
EXPOSE 3000

# Comando de inicio
CMD ["serve", "-s", "dist", "-l", "3000"]
