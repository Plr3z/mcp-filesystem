FROM supercorp/supergateway:latest

USER root

# Dependências necessárias (SEM FUSE)
RUN apk add --no-cache \
    nodejs \
    npm \
    ca-certificates

WORKDIR /app

# Instala o MCP Filesystem Server
RUN npm install -g @modelcontextprotocol/server-filesystem

# Variáveis de ambiente (usadas pelo SDK)
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"
ENV S3_BUCKET=""
ENV S3_PREFIX="filesystem"

EXPOSE 3001

# ENTRYPOINT sem montagem de FS
ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Iniciando Supergateway com MCP Filesystem (S3 API, sem FUSE)...' && \
  supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem s3://$S3_BUCKET/$S3_PREFIX\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
