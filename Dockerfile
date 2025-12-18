FROM node:20-alpine

RUN apk add --no-cache rclone ca-certificates

WORKDIR /app
RUN mkdir -p /app/s3data /app/config /app/cache && chmod -R 777 /app

ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache
ENV AWS_REGION="us-east-2"
ENV PATH=$PATH:/usr/local/bin

RUN npm install -g supergateway @modelcontextprotocol/server-filesystem

EXPOSE 3001

ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Verificando credenciais...' && \
  if [ -z \"$AWS_ACCESS_KEY_ID\" ]; then echo 'ERRO: AWS_ACCESS_KEY_ID esta vazia'; fi && \
  echo 'Configurando Rclone...' && \
  rclone config create mys3 s3 provider=AWS env_auth=true region=$AWS_REGION && \
  echo 'Sincronizando arquivos do S3...' && \
  rclone sync mys3:$S3_BUCKET /app/s3data -v && \
  echo 'Iniciando Supergateway...' && \
  supergateway --stdio \"npx @modelcontextprotocol/server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
