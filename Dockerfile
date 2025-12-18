FROM node:20-alpine

# Instala rclone e dependências
RUN apk add --no-cache rclone ca-certificates fuse3

WORKDIR /app

# Criamos as pastas onde o S3 será "espelhado"
RUN mkdir -p /app/s3data /app/.config/rclone && \
    chmod -R 777 /app

# Variáveis para o Rclone (usaremos as ENVs que você já tem)
ENV RCLONE_CONFIG_MYS3_TYPE=s3 \
    RCLONE_CONFIG_MYS3_PROVIDER=AWS \
    RCLONE_CONFIG_MYS3_REGION=us-east-2 \
    RCLONE_CONFIG_MYS3_ACCESS_KEY_ID=$AWSACCESSKEYID \
    RCLONE_CONFIG_MYS3_SECRET_ACCESS_KEY=$AWSSECRETACCESSKEY

EXPOSE 3001

# O segredo aqui: rclone serve http ou rclone mount em modo simples
# Vamos usar o rclone para sincronizar ou montar em background
ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Iniciando sincronização do S3...' && \
  rclone config create mys3 s3 env_auth=true region=us-east-2 && \
  (rclone mount mys3:$S3_BUCKET /app/s3data --vfs-cache-mode full --daemon-timeout 10m --allow-other --vfs-cache-max-age 24h &) && \
  sleep 5 && \
  echo 'Iniciando Supergateway com Filesystem MCP...' && \
  supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
