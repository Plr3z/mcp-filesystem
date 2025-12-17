FROM supercorp/supergateway:latest

USER root
RUN apk add --no-cache nodejs npm ca-certificates

WORKDIR /app

# instalar MCP filesystem localmente (não global)
RUN npm install @modelcontextprotocol/server-filesystem

# variáveis de ambiente
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"
ENV S3_BUCKET=""
ENV S3_PREFIX="filesystem"

EXPOSE 3001

# muda para UID aleatório (OpenShift vai setar)
USER 1001

# ENTRYPOINT sem global npm, usando npx do pacote local
ENTRYPOINT ["/bin/sh","-c","echo 'Iniciando Supergateway com MCP Filesystem (S3 API, sem FUSE)...' && npx @modelcontextprotocol/server-filesystem s3://$S3_BUCKET/$S3_PREFIX --stdio --port 3001 --baseUrl http://0.0.0.0:3001 --ssePath /sse --messagePath /message"]
