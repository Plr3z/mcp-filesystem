FROM supercorp/supergateway:latest

USER root
RUN apk add --no-cache nodejs npm ca-certificates aws-cli

WORKDIR /app

# Instala o MCP localmente
RUN npm install @modelcontextprotocol/server-filesystem

# Cria a pasta de sync com permissões para o OpenShift
RUN mkdir -p /mnt/s3-local && chown -R 1001:0 /app /mnt/s3-local && chmod -R 775 /mnt/s3-local

EXPOSE 3001
USER 1001

# ENTRYPOINT corrigido para evitar erro de parse de argumentos e de assinatura AWS
ENTRYPOINT ["/bin/sh", "-c", "\
  echo '📥 Sincronizando S3...'; \
  aws s3 sync s3://$S3_BUCKET /mnt/s3-local --region $AWS_REGION || echo '⚠️ Falha no sync'; \
  echo '🚀 Iniciando MCP...'; \
  npx @modelcontextprotocol/server-filesystem /mnt/s3-local --stdio \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
