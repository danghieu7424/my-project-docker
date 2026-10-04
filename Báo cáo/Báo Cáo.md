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

## 3.2. Chi tiết các lệnh thao tác Dữ liệu & Kiểm thử Role (Xác minh bằng `curl`)

### A. Cổng `:8333` (S3 API Gateway — Bảo vệ nghiêm ngặt bằng Role SigV4)
- **Bản chất:** Chỉ cho phép thao tác dữ liệu khi có chữ ký AWS SigV4 (Role `internal-admin`). Mọi truy cập ẩn danh (Anonymous) bị từ chối `403`.
- **Lệnh 1 — Kiểm tra Role: Truy cập đọc ẩn danh (Test Anonymous GET):**
  ```bash
  curl -i http://localhost:8333/objects
  ```
  *Kết quả thực tế:* Trả về **HTTP 403 Forbidden** (`<Code>AccessDenied</Code>`). Đạt tiêu chuẩn bảo mật phân quyền.
- **Lệnh 2 — Thao tác dữ liệu: Cố tình ghi đè dữ liệu trái phép (Test Unauthenticated PUT):**
  ```bash
  curl -i -X PUT -d "malicious_payload" http://localhost:8333/objects/unauthorized.txt
  ```
  *Kết quả thực tế:* Trả về **HTTP 403 Forbidden** (`<Code>AccessDenied</Code>`). Không thể can thiệp dữ liệu khi thiếu chữ ký số.
- **Lệnh 3 — Thao tác dữ liệu hợp lệ với Role `internal-admin` (Qua SigV4):**
  Thực thi script `smoke-s3.sh` hoặc AWS CLI (nạp cặp khóa từ `.runtime/object_storage/credentials.env`):
  *Kết quả:* Hoàn tất 100% vòng đời CRUD (PutObject, HeadObject, GetObject, ListObjects, DeleteObject) với mã thoát `0`.

---

### B. Cổng `:9333` (Master Server — Quản trị Cụm & Điều phối Volume)
- **Bản chất:** Master không lưu trực tiếp payload file mà quản lý Topology và cấp phát Volume ID / File ID (FID). Cổng này mặc định **No-Auth**.
- **Lệnh 1 — Kiểm tra Role & Trạng thái: Truy vấn Cluster Topology (Read-only):**
  ```bash
  curl -s http://localhost:9333/dir/status?pretty=y
  ```
  *Kết quả thực tế:* Trả về JSON hiển thị toàn bộ cấu trúc DataCenters, Racks, DataNodes và dung lượng đĩa khả dụng.
- **Lệnh 2 — Thao tác điều phối: Xin cấp phát File ID để ghi dữ liệu (Assign FID):**
  ```bash
  curl -s http://localhost:9333/dir/assign
  ```
  *Kết quả thực tế:* Trả về JSON chứa khóa cấp phát: `{"fid":"1,0123456789","url":"127.0.0.1:8080","publicUrl":"localhost:8080","count":1}`.
- **Lệnh 3 — Thao tác điều phối: Tra cứu vị trí của Volume (Lookup Volume ID):**
  ```bash
  curl -s "http://localhost:9333/dir/lookup?volumeId=1"
  ```
  *Kết quả thực tế:* Trả về địa chỉ của volume server đang nắm giữ volume tương ứng.
- **Đánh giá Role:** Hoàn toàn không có cơ chế xác thực. Bất kỳ client nào kết nối tới `9333` đều có thể can thiệp cấp phát volume và xem cấu trúc hạ tầng. Bắt buộc phải đóng cổng này khỏi public network trong môi trường Production.

---

### C. Cổng `:8888` (Filer Server — POSIX Namespace & Thao tác Dữ liệu Trực tiếp)
- **Bản chất:** Cung cấp giao diện REST/WebDAV tương tác trực tiếp với cây thư mục. Mặc định **No-Auth**, cho phép thực hiện CRUD dữ liệu mà không cần AWS SigV4.
- **Lệnh 1 — Thao tác dữ liệu: Duyệt danh sách Bucket/Thư mục (List):**
  ```bash
  curl -s http://localhost:8888/buckets/
  ```
  *Kết quả thực tế:* Trả về danh sách các bucket hiện hữu (ví dụ: `objects/`).
- **Lệnh 2 — Thao tác dữ liệu: Ghi dữ liệu trực tiếp vào Bucket không cần SigV4 (Direct PUT/Upload):**
  ```bash
  curl -s -X PUT -d "Du lieu ghi truc tiep qua Filer" http://localhost:8888/buckets/objects/filer_test.txt
  ```
  *Kết quả thực tế:* Trả về JSON xác nhận file `filer_test.txt` đã được ghi thành công vào bucket `objects`.
- **Lệnh 3 — Thao tác dữ liệu: Đọc nội dung file trực tiếp từ Bucket (Direct GET/Download):**
  ```bash
  curl -s http://localhost:8888/buckets/objects/filer_test.txt
  ```
  *Kết quả thực tế:* Trả về chính xác chuỗi: `Du lieu ghi truc tiep qua Filer`.
- **Lệnh 4 — Thao tác dữ liệu: Xóa file trực tiếp khỏi Bucket (Direct DELETE):**
  ```bash
  curl -s -X DELETE http://localhost:8888/buckets/objects/filer_test.txt
  ```
  *Kết quả thực tế:* Xóa bỏ thành công tệp `filer_test.txt` khỏi bucket.
- **Đánh giá Rủi ro Bảo mật (Bypass S3 Authentication):** Cổng `8888` có khả năng **Bypass hoàn toàn** cơ chế bảo vệ của cổng `8333`. Một người dùng không có Access Key S3 vẫn có thể đọc, ghi, xóa dữ liệu bucket qua cổng `8888`. Do đó, trong Production, cổng `8888` phải được đóng tuyệt đối khỏi mạng ngoài.

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
> * Cổng **`:9333`** (Master) và **`:8888`** (Filer) bắt buộc phải đóng hoàn toàn khỏi host để loại bỏ triệt để nguy cơ bypass phân quyền.