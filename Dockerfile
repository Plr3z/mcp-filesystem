FROM supercorp/supergateway:latest

USER root
RUN apk add --no-cache nodejs npm ca-certificates

WORKDIR /app

# instalar MCP filesystem localmente (não global)
RUN npm install @modelcontextprotocol/server-filesystem

# variáveis de ambiente padrão
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"
ENV S3_BUCKET=""
ENV S3_PREFIX="filesystem"

EXPOSE 3001

# muda para UID não-root (OpenShift vai sobrescrever)
USER 1001

# ENTRYPOINT seguro, usando npx local e S3 URI
ENTRYPOINT ["/bin/sh","-c","echo 'Iniciando Supergateway com MCP Filesystem (S3 API, sem FUSE)...' && npx @modelcontextprotocol/server-filesystem s3://$S3_BUCKET/$S3_PREFIX --stdio --port 3001 --baseUrl http://0.0.0.0:3001 --ssePath /sse --messagePath /message"]
