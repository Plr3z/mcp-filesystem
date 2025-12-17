FROM supercorp/supergateway:latest

USER root

RUN apk add --no-cache nodejs npm ca-certificates

WORKDIR /app

# npm cache seguro
RUN mkdir -p /app/.npm && chmod -R 777 /app/.npm
ENV npm_config_cache=/app/.npm

# instala o MCP filesystem
RUN npm install -g @modelcontextprotocol/server-filesystem

# variáveis de ambiente
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"
ENV S3_BUCKET=""
ENV S3_PREFIX="filesystem"

EXPOSE 3001

# rodar como usuário não-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# ENTRYPOINT seguro sem script externo
ENTRYPOINT ["/bin/sh", "-c", "echo 'Iniciando Supergateway com MCP Filesystem (S3 API, sem FUSE)...' && supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem s3://$S3_BUCKET/$S3_PREFIX\" --port 3001 --baseUrl http://0.0.0.0:3001 --ssePath /sse --messagePath /message"]
