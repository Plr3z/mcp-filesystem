FROM node:20-alpine

RUN apk add --no-cache rclone ca-certificates

WORKDIR /app

# Instalamos os pacotes globalmente
RUN npm install -g supergateway @modelcontextprotocol/server-filesystem

# Criamos as pastas necessárias com permissões amplas para o OpenShift
RUN mkdir -p /app/s3data /app/config /app/cache /app/.npm-cache && \
    chmod -R 777 /app

# Variáveis de ambiente para evitar que o NPM/Rclone tentem escrever na raiz /
ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache
ENV NPM_CONFIG_CACHE=/app/.npm-cache
ENV AWS_REGION="us-east-2"
ENV PATH=$PATH:/usr/local/bin

EXPOSE 3001

ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Sincronizando arquivos do S3...' && \
  rclone sync :s3:$S3_BUCKET /app/s3data \
    --s3-provider=AWS \
    --s3-access-key-id=\"$AWS_ACCESS_KEY_ID\" \
    --s3-secret-access-key=\"$AWS_SECRET_ACCESS_KEY\" \
    --s3-region=\"$AWS_REGION\" && \
  echo 'Iniciando Supergateway...' && \
  supergateway --stdio \"mcp-server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
