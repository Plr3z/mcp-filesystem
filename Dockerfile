FROM supercorp/supergateway:latest

USER root
RUN apk add --no-cache nodejs npm ca-certificates

WORKDIR /app

# usar cache npm no diretório temporário gravável
ENV npm_config_cache=/tmp/.npm

# instalar MCP filesystem globalmente com permissões seguras
RUN npm install -g --unsafe-perm @modelcontextprotocol/server-filesystem

# variáveis de ambiente
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"
ENV S3_BUCKET=""
ENV S3_PREFIX="filesystem"

EXPOSE 3001

# rodar como qualquer UID (OpenShift vai setar automaticamente)
USER 1001

ENTRYPOINT ["/bin/sh", "-c", "echo 'Iniciando Supergateway com MCP Filesystem (S3 API, sem FUSE)...' && supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem s3://$S3_BUCKET/$S3_PREFIX\" --port 3001 --baseUrl http://0.0.0.0:3001 --ssePath /sse --messagePath /message"]
