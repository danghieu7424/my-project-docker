ARG REGISTRY=""
FROM ${REGISTRY}chrislusf/seaweedfs:3.59

# Ensure running offline by avoiding apk add (no internet access).
# The base image already contains the weed binary.

RUN addgroup -S -g 10001 storagegroup && \
    adduser -S -u 10001 -G storagegroup -h /home/storageuser storageuser

WORKDIR /app

RUN mkdir -p /data/s3 /data/filer /data/volume /etc/object_storage && \
    chown -R storageuser:storagegroup /data /app /etc/object_storage

COPY s3.json /etc/object_storage/s3.json

USER 10001:10001

EXPOSE 8333

ENTRYPOINT ["weed", "server", "-dir=/data", "-s3", "-s3.port=8333", "-s3.config=/etc/object_storage/s3.json"]