FROM node:20-alpine

RUN apk add --no-cache rclone ca-certificates

WORKDIR /app

# Instalamos os pacotes e limpamos o cache para economizar espaço
RUN npm install -g supergateway @modelcontextprotocol/server-filesystem && \
    npm cache clean --force

# Criamos as pastas necessárias com permissões totais para o usuário do OpenShift
RUN mkdir -p /app/s3data /app/config /app/cache /app/.npm-global && \
    chmod -R 777 /app

# Configurações para o Rclone e NPM rodarem sem root
ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache
ENV NPM_CONFIG_PREFIX=/app/.npm-global
ENV PATH=$PATH:/app/.npm-global/bin:/usr/local/bin
ENV AWS_REGION="us-east-2"

EXPOSE 3001

# ... (mantenha o topo igual)

ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Sincronizando S3...' && \
  rclone sync :s3:$S3_BUCKET /app/s3data \
    --s3-provider=AWS \
    --s3-access-key-id=\"$AWS_ACCESS_KEY_ID\" \
    --s3-secret-access-key=\"$AWS_SECRET_ACCESS_KEY\" \
    --s3-region=\"$AWS_REGION\" && \
  echo 'Iniciando Supergateway...' && \
  supergateway --stdio \"mcp-server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl \"$EXTERNAL_URL\" \
    --cors=\"*\" \
    --ssePath /sse \
    --messagePath /message \
"]
