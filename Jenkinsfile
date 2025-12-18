FROM node:20-alpine

RUN apk add --no-cache rclone ca-certificates fuse3

WORKDIR /app
# Criamos as pastas e garantimos permissão total nelas para o usuário aleatório do OpenShift
RUN mkdir -p /app/s3data /app/config /app/cache && chmod -R 777 /app

# Apontamos o Rclone para usar a pasta local
ENV RCLONE_CONFIG=/app/config/rclone.conf
ENV RCLONE_CACHE_DIR=/app/cache

EXPOSE 3001

ENTRYPOINT ["/bin/sh", "-c", "\
  rclone config create mys3 s3 env_auth=true region=$AWS_REGION && \
  (rclone mount mys3:$S3_BUCKET /app/s3data --vfs-cache-mode full --daemon-timeout 10m &) && \
  sleep 5 && \
  supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem /app/s3data\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
