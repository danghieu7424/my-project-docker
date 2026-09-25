# Object Storage - QA Evidence Report

## 1. M07 — Baseline (v1.0 / OS-01)
### 1.1. Image Build Offline
- **Status:** Hoàn thành.
- **Source Link:** [`object_storage/Dockerfile`](./object_storage/Dockerfile)
- **Minh chứng:** Đã hỗ trợ build offline trong môi trường Air-gapped (không internet) thông qua tham số `REGISTRY`. Người dùng có thể truyền private registry (VD: Harbor/Nexus) để kéo base image: `docker build --build-arg REGISTRY=harbor.local/ ...`. Đồng thời, cấu trúc Dockerfile đã loại bỏ hoàn toàn các lệnh `apk add` (yêu cầu internet) và ánh xạ trực tiếp cấu hình `s3.json` (`COPY s3.json /etc/object_storage/s3.json`).

### 1.2. Smoke Test (`smoke-s3.sh`) exit 0
- **Status:** Hoàn thành.
- **Source Link:** [`object_storage/smoke-s3.sh`](./object_storage/smoke-s3.sh)
- **Minh chứng:** Kịch bản test thực thi thành công, kết nối với S3 port 8333, thực hiện full CRUD lifecycle và kết thúc với `exit 0`. Dưới đây là log thực thi:

```bash
$ docker run --rm --entrypoint bash --network my-project_default -e S3_ENDPOINT=http://object-storage:8333 -v "${PWD}/object_storage:/scripts" -w /scripts amazon/aws-cli ./smoke-s3.sh
=== 1. Tạo bucket 'objects' ===
make_bucket failed: s3://objects An error occurred (BucketAlreadyExists) when calling the CreateBucket operation...
=== 2. PutObject ===
=== 3. ListObjectsV2 ===
2026-09-17 06:18:47         29 probe.txt
=== 4. GetObject ===
Nội dung xác minh: ping_test_payload_1789625926
=== 5. DeleteObject ===
delete: s3://objects/probe.txt
SMOKE TEST THÀNH CÔNG (Mã thoát 0)
```

## 2. Enterprise / OS-02
### 2.1. S3 Healthcheck
- **Status:** Hoàn thành.
- **Source Link:** [`docker-compose.yml`](./docker-compose.yml) (section `healthcheck`)
- **Minh chứng:** S3 container được giám sát sức khỏe liên tục. Thay vì sử dụng `curl` (yêu cầu cài đặt thêm qua apk), Healthcheck được cấu hình sử dụng lệnh `wget -qO-` có sẵn trong base image:
  `test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:8333/ > /dev/null || exit 1"]`

### 2.2. Phương án HA & RPO
- **Status:** Đã cập nhật.
- **Source Link:** [`object_storage/VERSION`](./object_storage/VERSION)
- **Minh chứng:** Do mô hình hiện tại là Single-node (chưa cấu hình cluster), file `VERSION` đã được cập nhật tường minh để xác nhận ranh giới thiết kế, tuân thủ yêu cầu:
  ```yaml
  ha: none
  rpo: 24h
  ```

### 2.3. Backup/Restore & Restore Drill
- **Status:** Hoàn thành.
- **Source Link:** [`object_storage/backup-restore.sh`](./object_storage/backup-restore.sh)
- **Minh chứng:** Kịch bản Backup/Restore tự động đã được triển khai, tận dụng chính volume và binary trong container (tar) để không phụ thuộc vào tool ở host. Dưới đây là log thực tế của quá trình Restore Drill (Diễn tập khôi phục):

```bash
# 1. Bơm dữ liệu giả lập
$ docker run --rm -v "${PWD}:/workspace" -w /workspace --network my-project_default -e AWS_ACCESS_KEY_ID=STORAGE_ADMIN_KEY -e AWS_SECRET_ACCESS_KEY=STORAGE_ADMIN_SECRET -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://object-storage:8333 s3 cp important_data.txt s3://objects/
upload: ./important_data.txt to s3://objects/important_data.txt 

# 2. Thực hiện Backup
$ docker run --rm --volumes-from object-storage -v "${BACKUP_DIR}:/backup" --entrypoint sh "object-storage:3.59" -c "tar czf /backup/$BACKUP_FILE /data"
=== Backup thanh cong vao: D:\all_projects\Works\my-project\backup_data\s3_backup_20260917_132645.tar.gz ===

# 3. Giả lập thảm họa (Xóa file)
$ docker run --rm --network my-project_default -e AWS_ACCESS_KEY_ID=STORAGE_ADMIN_KEY -e AWS_SECRET_ACCESS_KEY=STORAGE_ADMIN_SECRET -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://object-storage:8333 s3 rm s3://objects/important_data.txt
delete: s3://objects/important_data.txt

# 4. Thực hiện Restore
$ docker stop object-storage
$ docker run --rm --volumes-from object-storage -v "${BACKUP_DIR}:/backup" --entrypoint sh "object-storage:3.59" -c "rm -rf /data/* && tar xzf /backup/$BACKUP_FILE -C /"
$ docker start object-storage
=== Khoi phuc hoan tat. Cho he thong 5 giay de boot up... ===

# 5. Kiểm tra sau khôi phục
$ docker run --rm --network my-project_default -e AWS_ACCESS_KEY_ID=STORAGE_ADMIN_KEY -e AWS_SECRET_ACCESS_KEY=STORAGE_ADMIN_SECRET -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://object-storage:8333 s3 ls s3://objects/
2026-09-17 06:26:45         66 important_data.txt
```
