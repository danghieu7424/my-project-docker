FROM chrislusf/seaweedfs:3.59 AS upstream

FROM alpine:3.19

RUN apk add --no-cache curl ca-certificates tzdata

RUN addgroup -S -g 10001 storagegroup && \
    adduser -S -u 10001 -G storagegroup -h /home/storageuser storageuser

WORKDIR /app

COPY --from=upstream /usr/bin/weed /usr/local/bin/weed
RUN chmod +x /usr/local/bin/weed

RUN mkdir -p /data/s3 /data/filer /data/volume && \
    chown -R storageuser:storagegroup /data /app

COPY config/s3.json /etc/object_storage/s3.json
RUN chown -R storageuser:storagegroup /etc/object_storage

USER 10001:10001

EXPOSE 8333

ENTRYPOINT ["weed", "server", "-dir=/data", "-s3", "-s3.port=8333", "-s3.config=/etc/object_storage/s3.json"]