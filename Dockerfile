FROM supercorp/supergateway:latest

USER root
RUN apk add --no-cache nodejs npm ca-certificates aws-cli

WORKDIR /app

# Instala o MCP localmente
RUN npm install @modelcontextprotocol/server-filesystem

# Cria a pasta de sync e dá permissão total para o usuário do OpenShift (1001)
RUN mkdir -p /mnt/s3-local && chown -R 1001:0 /app /mnt/s3-local && chmod -R 775 /mnt/s3-local

# Variáveis de ambiente (o Deployment já injeta estas)
ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_REGION="us-east-2" \
    S3_BUCKET=""

EXPOSE 3001
USER 1001

# Ajustes no ENTRYPOINT:
# 1. Aspas duplas em "${AWS_SECRET_ACCESS_KEY}" evitam erro de assinatura por caracteres como '/'
# 2. Ordem corrigida do npx: [pacote] [caminho] [opções]
ENTRYPOINT ["/bin/sh", "-c", "\
  echo '📥 Sincronizando arquivos do S3...'; \
  aws s3 sync s3://\"${S3_BUCKET}\" /mnt/s3-local --region \"${AWS_REGION}\" || echo '⚠️ Falha no sync, prosseguindo...'; \
  echo '🚀 Iniciando Supergateway com MCP Filesystem...'; \
  npx @modelcontextprotocol/server-filesystem /mnt/s3-local --stdio \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
