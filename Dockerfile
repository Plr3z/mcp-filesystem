FROM node:20-alpine

# Instala rclone e dependências
RUN apk add --no-cache rclone ca-certificates

WORKDIR /app

# Instala o supergateway e o servidor filesystem localmente para garantir o PATH
RUN npm install -g supergateway @modelcontextprotocol/server-filesystem

# Criamos as pastas e garantimos permissão para o usuário aleatório do OpenShift
RUN mkdir -p /app/s3data /app/config /app/cache && chmod -R 777 /app

# FORÇA o rclone a usar pastas onde temos permissão de escrita
ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache
ENV AWS_REGION="us-east-2"
# Garante que os binários do NPM instalados globalmente sejam encontrados
ENV PATH=$PATH:/usr/local/bin

EXPOSE 3001

# Lógica: 1. Configura S3 -> 2. Sincroniza (Download) -> 3. Inicia MCP
ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Configurando Rclone...' && \
  rclone config create mys3 s3 env_auth=true region=$AWS_REGION && \
  echo 'Sincronizando arquivos do S3 (Download)...' && \
  rclone sync mys3:$S3_BUCKET /app/s3data && \
  echo 'Iniciando Supergateway...' && \
  supergateway --stdio \"npx @modelcontextprotocol/server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
