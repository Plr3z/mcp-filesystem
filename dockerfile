FROM supercorp/supergateway:latest

USER root

# Dependências necessárias
RUN apk add --no-cache \
    fuse \
    s3fs-fuse \
    nodejs \
    npm \
    ca-certificates

RUN echo "user_allow_other" >> /etc/fuse.conf

RUN mkdir -p /mnt/s3/filesystem

ENV AWSACCESSKEYID=""
ENV AWSSECRETACCESSKEY=""
ENV S3_BUCKET=""

EXPOSE 3001

ENTRYPOINT ["/bin/sh", "-c", "\
  echo \"$AWSACCESSKEYID:$AWSSECRETACCESSKEY\" > /etc/passwd-s3fs && \
  chmod 600 /etc/passwd-s3fs && \
  mkdir -p /mnt/s3/filesystem && \
  echo 'Montando S3...' && \
  s3fs $S3_BUCKET /mnt/s3/filesystem \
    -o passwd_file=/etc/passwd-s3fs \
    -o allow_other \
    -o nonempty \
    -o endpoint=us-east-2 \
    -o dbglevel=info & \  
  sleep 5 && \
  echo 'Bucket montado com sucesso!' && \
  echo 'Iniciando Supergateway com MCP Filesystem...' && \
  supergateway --stdio \"npx -y @modelcontextprotocol/server-filesystem /mnt/s3/filesystem\" \
    --port 3001 \
    --baseUrl http://0.0.0.0:3001 \
    --ssePath /sse \
    --messagePath /message \
"]
