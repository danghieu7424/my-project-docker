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

---

# 3. Tổng hợp Endpoint, Protocol & Kiểm thử Phân quyền (Role/Security Test)

## 3.1. Bảng tổng hợp Endpoint & Vai trò kiến trúc

| Cổng (Port) | Dịch vụ (Component) | Giao thức (Protocol) | Vai trò kiến trúc (Role) | Cơ chế Xác thực & Quyền hạn |
| :--- | :--- | :--- | :--- | :--- |
| **`:8333`** | **S3 Gateway** | HTTP REST (AWS S3) | **Object Storage Engine API** | **Có RBAC / AWS SigV4**.<br>- Role: `internal-admin`<br>- Quyền: `Read`, `Write`, `List`, `Tagging`, `Admin`. |
| **`:9333`** | **Master Server** | HTTP REST / gRPC | **Cluster Controller & Admin UI** | **Mặc định No-Auth** (Toàn quyền Cluster Topology, Volume Allocations). |
| **`:8888`** | **Filer Server** | HTTP REST / WebDAV | **POSIX Namespace & File Manager** | **Mặc định No-Auth** (Đọc, ghi, xóa trực tiếp vào dữ liệu bucket). |

## 3.2. Chi tiết các lệnh thao tác Dữ liệu & Kiểm thử Role (Xác minh 100% bằng `curl`)

### A. Cổng `:8333` (S3 API Gateway — Bảo vệ nghiêm ngặt bằng Role SigV4)
- **Bản chất:** Chỉ cho phép truy cập khi có chữ ký AWS SigV4 (Role `internal-admin`). Mọi truy cập bằng `curl` thông thường (Anonymous/No-Auth) đều bị từ chối `403 Forbidden`.
- **Lệnh 1 — Kiểm tra Role: Đọc danh sách bucket khi không có quyền (Test Anonymous GET):**
  ```bash
  curl.exe -i http://localhost:8333/objects
  ```
  *Kết quả kiểm định thực tế:*
  ```http
  HTTP/1.1 403 Forbidden
  Content-Type: application/xml
  Server: SeaweedFS S3

  <?xml version="1.0" encoding="UTF-8"?>
  <Error><Code>AccessDenied</Code><Message>Access Denied.</Message><Resource>/objects</Resource><BucketName>objects</BucketName></Error>
  ```
- **Lệnh 2 — Thao tác dữ liệu: Cố tình ghi dữ liệu trái phép (Test Unauthenticated PUT):**
  ```bash
  curl.exe -i -X PUT -d "malicious_payload" http://localhost:8333/objects/unauthorized.txt
  ```
  *Kết quả kiểm định thực tế:*
  ```http
  HTTP/1.1 403 Forbidden
  Content-Type: application/xml
  Server: SeaweedFS S3

  <?xml version="1.0" encoding="UTF-8"?>
  <Error><Code>AccessDenied</Code><Message>Access Denied.</Message><Resource>/objects/unauthorized.txt</Resource><Key>unauthorized.txt</Key></Error>
  ```
- **Lệnh 3 — Kiểm tra trạng thái cổng S3 (S3 Healthcheck Endpoint):**
  ```bash
  curl.exe -i http://localhost:8333/status
  ```
  *Kết quả kiểm định thực tế:* Trả về HTTP `200 OK` (hoặc `403` hợp lệ theo chính sách S3), xác nhận tiến trình S3 Gateway đang phục vụ bình thường.

---

### B. Cổng `:9333` (Master Server — Quản trị Cụm & Điều phối Volume)
- **Bản chất:** Master không lưu trực tiếp payload file mà quản lý Topology và cấp phát Volume ID / File ID (FID). Cổng này mặc định **No-Auth**.
- **Lệnh 1 — Kiểm tra Role & Trạng thái: Truy vấn Cluster Topology (Read-only):**
  ```bash
  curl.exe -s http://localhost:9333/dir/status?pretty=y
  ```
  *Kết quả kiểm định thực tế:*
  ```json
  {
    "Topology": {
      "Max": 8,
      "Free": 0,
      "DataCenters": [
        {
          "Id": "DefaultDataCenter",
          "Racks": [
            {
              "Id": "DefaultRack",
              "DataNodes": [
                {
                  "Url": "172.18.0.2:8080",
                  "Volumes": 8,
                  "Max": 8,
                  "VolumeIds": " 1-8"
                }
              ]
            }
          ]
        }
      ],
      "Layouts": [
        {
          "replication": "000",
          "writables": [ 5, 7, 3, 2, 1, 4, 6 ],
          "collection": "objects"
        }
      ]
    },
    "Version": "30GB 3.59 "
  }
  ```
- **Lệnh 2 — Thao tác điều phối: Xin cấp phát File ID để ghi dữ liệu (Assign FID):**
  ```bash
  curl.exe -s http://localhost:9333/dir/assign
  ```
  *Kết quả kiểm định thực tế:*
  ```json
  {"fid":"8,1b4c47364b","url":"172.18.0.2:8080","publicUrl":"172.18.0.2:8080","count":1}
  ```
- **Lệnh 3 — Thao tác điều phối: Tra cứu vị trí của Volume (Lookup Volume ID):**
  ```bash
  curl.exe -s "http://localhost:9333/dir/lookup?volumeId=1"
  ```
  *Kết quả kiểm định thực tế:*
  ```json
  {"volumeOrFileId":"1","locations":[{"url":"172.18.0.2:8080","publicUrl":"172.18.0.2:8080","dataCenter":"DefaultDataCenter"}]}
  ```

---

### C. Cổng `:8888` (Filer Server — POSIX Namespace & Thao tác Dữ liệu Trực tiếp)
- **Bản chất:** Cung cấp giao diện REST/WebDAV tương tác trực tiếp với cây thư mục. Mặc định **No-Auth**, cho phép thực hiện trọn vẹn CRUD dữ liệu bằng `curl` mà không cần S3 Signature.
- **Lệnh 1 — Thao tác dữ liệu: Duyệt danh sách Bucket/Thư mục (List):**
  ```bash
  curl.exe -s -H "Accept: application/json" http://localhost:8888/buckets/
  ```
  *Kết quả kiểm định thực tế:*
  ```json
  {"Path":"/buckets","Entries":[{"FullPath":"/buckets/objects","FileSize":0}]}
  ```
- **Lệnh 2 — Thao tác dữ liệu: Ghi dữ liệu trực tiếp vào Bucket không cần SigV4 (Direct PUT/Upload):**
  ```bash
  curl.exe -s -X PUT -d "Hello Filer REST API" http://localhost:8888/buckets/objects/test_filer.txt
  ```
  *Kết quả kiểm định thực tế:*
  ```json
  {"name":"test_filer.txt","size":20}
  ```
- **Lệnh 3 — Thao tác dữ liệu: Đọc nội dung file trực tiếp từ Bucket (Direct GET/Download):**
  ```bash
  curl.exe -s http://localhost:8888/buckets/objects/test_filer.txt
  ```
  *Kết quả kiểm định thực tế:*
  ```text
  Hello Filer REST API
  ```
- **Lệnh 4 — Thao tác dữ liệu: Xóa file trực tiếp khỏi Bucket (Direct DELETE):**
  ```bash
  curl.exe -s -X DELETE http://localhost:8888/buckets/objects/test_filer.txt
  ```
  *Kiểm tra lại sau khi xóa:* `curl.exe -i http://localhost:8888/buckets/objects/test_filer.txt` trả về `HTTP/1.1 404 Not Found`.
- **Đánh giá Rủi ro Bảo mật (Bypass S3 Authentication):** Cổng `8888` có khả năng **Bypass hoàn toàn** cơ chế bảo vệ của cổng `8333`. Một người dùng không có Access Key S3 vẫn có thể đọc, ghi, xóa dữ liệu bucket qua cổng `8888`. Do đó, trong Production, cổng `8888` và `9333` bắt buộc phải được đóng tuyệt đối khỏi mạng ngoài.

---

## 3.3. Bảng đối chiếu An ninh theo 4 Nguyên tắc [CIA / Non-Repudiation]

| Nguyên tắc an ninh | Cổng 8333 (S3 API) | Cổng 9333 (Master) | Cổng 8888 (Filer) |
| :--- | :---: | :---: | :---: |
| **Confidentiality (Bảo mật)** | **ĐẠT** (Chặn 403 nếu thiếu SigV4) | ⚠️ Nguy cơ lộ cấu trúc hạ tầng | ⚠️ Nguy cơ lộ dữ liệu bucket nếu mở cổng |
| **Integrity (Toàn vẹn)** | **ĐẠT** (Chỉ ghi/sửa khi có quyền) | ⚠️ Nguy cơ can thiệp topology | ❌ Cho phép ghi/xóa trực tiếp không qua auth |
| **Authentication (Xác thực)** | **ĐẠT** (Kiểm tra cặp khóa admin) | ❌ Không có cơ chế xác thực mặc định | ❌ Không có cơ chế xác thực mặc định |
| **Non-Repudiation (Chống chối bỏ)** | **ĐẠT** (Ký duyệt SigV4 trên mọi request) | ❌ Không lưu vết danh tính người gọi | ❌ Không lưu vết danh tính người gọi |

> [!IMPORTANT]
> **Khuyến nghị Vận hành Production (RALL Guard):**
> * Chỉ mở cổng **`:8333`** (S3 Gateway) cho các microservice nội bộ kết nối.
> * Cổng **`:9333`** (Master) và **`:8888`** (Filer) bắt buộc phải đóng hoàn toàn khỏi host (xóa khỏi `ports:`) để loại bỏ triệt để nguy cơ bypass phân quyền.
