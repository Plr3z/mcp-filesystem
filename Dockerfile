FROM supercorp/supergateway:latest

USER root

# Instala Node.js, NPM e o AWS CLI v2
RUN apk add --no-cache nodejs npm ca-certificates aws-cli

WORKDIR /app

# Instala o MCP Filesystem localmente
RUN npm install @modelcontextprotocol/server-filesystem

# Cria a pasta que servirá de cache local para o S3
# O diretório /mnt/s3-local será o "espelho" do seu bucket
RUN mkdir -p /mnt/s3-local && chmod 777 /mnt/s3-local

# Variáveis de ambiente (Devem ser preenchidas no Deployment do OpenShift)
ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_REGION="us-east-2" \
    S3_BUCKET=""

EXPOSE 3001

# O OpenShift roda com usuários aleatórios, então garantimos permissão no /app
RUN chown -R 1001:0 /app /mnt/s3-local
USER 1001

# ENTRYPOINT que sincroniza na subida
# Nota: Ele faz o download (sync) do S3 para o local e depois abre o MCP nessa pasta
ENTRYPOINT ["/bin/sh", "-c", "\
  echo '📥 Sincronizando arquivos do S3 para o disco local...'; \
  aws s3 sync s3://${S3_BUCKET} /mnt/s3-local --region ${AWS_REGION}; \
  echo '🚀 Iniciando MCP Filesystem em /mnt/s3-local...'; \
  npx @modelcontextprotocol/server-filesystem /mnt/s3-local \
    --stdio \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
