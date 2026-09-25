# Công việc đã làm:

- [x] Tạo cây thư mục theo hướng dẫn.
- [x] Viết cấu hình cho các file.
- [x] Kiểm thử môi trường với docker.

# Chi tiết kiểm thử:

## 1. Khởi tạo tác vụ.

```PowerShell
PS >> docker compose --profile object_storage build 
[+] Building 2.4s (20/20) FINISHED                                                                                                                                                                                                         
 => [internal] load local bake definitions                                                                                                                                                                                            0.0s
 => => reading from stdin 595B                                                                                                                                                                                                        0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                                                                  0.0s
 => => transferring dockerfile: 745B                                                                                                                                                                                                  0.0s
 => [internal] load metadata for docker.io/chrislusf/seaweedfs:3.59                                                                                                                                                                   1.8s
 => [internal] load metadata for docker.io/library/alpine:3.19                                                                                                                                                                        1.7s
 => [auth] chrislusf/seaweedfs:pull token for registry-1.docker.io                                                                                                                                                                    0.0s
 => [auth] library/alpine:pull token for registry-1.docker.io                                                                                                                                                                         0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                     0.0s
 => => transferring context: 2B                                                                                                                                                                                                       0.0s
 => [stage-1 1/9] FROM docker.io/library/alpine:3.19@sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1                                                                                                          0.0s
 => => resolve docker.io/library/alpine:3.19@sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1                                                                                                                  0.0s
 => [internal] load build context                                                                                                                                                                                                     0.0s
 => => transferring context: 62B                                                                                                                                                                                                      0.0s
 => [upstream 1/1] FROM docker.io/chrislusf/seaweedfs:3.59@sha256:5e777daf839770e9b370a183ecedba6752f63b719efd0ede1e271489c40c56af                                                                                                    0.0s
 => => resolve docker.io/chrislusf/seaweedfs:3.59@sha256:5e777daf839770e9b370a183ecedba6752f63b719efd0ede1e271489c40c56af                                                                                                             0.0s
 => CACHED [stage-1 2/9] RUN apk add --no-cache curl ca-certificates tzdata                                                                                                                                                           0.0s
 => CACHED [stage-1 3/9] RUN addgroup -S -g 10001 storagegroup &&     adduser -S -u 10001 -G storagegroup -h /home/storageuser storageuser                                                                                            0.0s
 => CACHED [stage-1 4/9] WORKDIR /app                                                                                                                                                                                                 0.0s
 => CACHED [stage-1 5/9] COPY --from=upstream /usr/bin/weed /usr/local/bin/weed                                                                                                                                                       0.0s
 => CACHED [stage-1 6/9] RUN chmod +x /usr/local/bin/weed                                                                                                                                                                             0.0s
 => CACHED [stage-1 7/9] RUN mkdir -p /data/s3 /data/filer /data/volume &&     chown -R storageuser:storagegroup /data /app                                                                                                           0.0s
 => CACHED [stage-1 8/9] COPY config/s3.json /etc/object_storage/s3.json                                                                                                                                                              0.0s
 => CACHED [stage-1 9/9] RUN chown -R storageuser:storagegroup /etc/object_storage                                                                                                                                                    0.0s
 => exporting to image                                                                                                                                                                                                                0.1s
 => => exporting layers                                                                                                                                                                                                               0.0s
 => => exporting manifest sha256:f3c620247dfd9aace294926c1961f06f12606990afc2bab11d0ca450ed9a52f3                                                                                                                                     0.0s
 => => exporting config sha256:425d7746117535e500d9775c5132c5981f3bae2330f96d61b5adc96e8f55ad7e                                                                                                                                       0.0s
 => => exporting attestation manifest sha256:e7a0d448e8055cb8469d3d579b5a2bbc1df2d0dbb0fdd0134161a66ec4153456                                                                                                                         0.0s
 => => exporting manifest list sha256:23cedc19ca852c1d3bc7940e8b1df561d77dfa8e6620593f9427ad8b1ef6491e                                                                                                                                0.0s
 => => naming to docker.io/library/object-storage:3.59                                                                                                                                                                                0.0s
 => => unpacking to docker.io/library/object-storage:3.59                                                                                                                                                                             0.0s
 => resolving provenance for metadata file                                                                                                                                                                                            0.0s
[+] build 1/1
 ✔ Image object-storage:3.59 Built
```

```PowerShell
PS >> docker compose --profile object_storage up -d
[+] up 2/2
 ✔ Network my-project_default Created                                                                                                                                                                                                  0.0s
 ✔ Container object-storage   Started          
```

```PowerShell
PS >> docker compose --profile object_storage ps   
NAME             IMAGE                 COMMAND                  SERVICE          CREATED              STATUS                        PORTS
object-storage   object-storage:3.59   "weed server -dir=/d…"   object_storage   About a minute ago   Up About a minute (healthy)   8333/tcp
```

#  2. Đóng tác vụ.
```PowerShell
PS >> docker compose --profile object_storage down 
[+] down 2/2
 ✔ Container object-storage   Removed                                                                                                                                                                                                  3.2s
 ✔ Network my-project_default Removed                                                                                                                                                                                                  0.2s
PS >> docker compose up -d                        
no service selected

What is next:
    Debug this Compose error with Gordon → docker ai "help me fix this compose error"

PS >> docker compose ps
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```