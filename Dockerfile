FROM node:20-alpine

RUN apk add --no-cache rclone ca-certificates

WORKDIR /app
RUN mkdir -p /app/s3data /app/config /app/cache && chmod -R 777 /app

ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache
ENV PATH=$PATH:/usr/local/bin

RUN npm install -g supergateway @modelcontextprotocol/server-filesystem

EXPOSE 3001

# Mudança: Passamos as variáveis diretamente no 'rclone config create'
ENTRYPOINT ["/bin/sh", "-c", "\
  echo 'Sincronizando arquivos do S3...' && \
  rclone sync :s3:$S3_BUCKET /app/s3data \
    --s3-provider=AWS \
    --s3-access-key-id=\"$AWS_ACCESS_KEY_ID\" \
    --s3-secret-access-key=\"$AWS_SECRET_ACCESS_KEY\" \
    --s3-region=\"$AWS_REGION\" \
    -v && \
  echo 'Iniciando Supergateway...' && \
  supergateway --stdio \"npx @modelcontextprotocol/server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
