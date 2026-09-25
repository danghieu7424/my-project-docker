```bash
cd  object_storage
Remove-Item -Recurse -Force src\.git
git clone --depth 1 --branch 3.59 https://github.com/seaweedfs/seaweedfs.git src
Copy-Item src\LICENSE -Destination LICENSE -Force
cd ..
docker compose --profile object_storage build --no-cache
docker images object-storage:3.59

docker compose --profile object_storage down
docker compose --profile object_storage build
docker compose --profile object_storage up -d
docker compose --profile object_storage ps
```
```Bash
docker exec object-storage wget -S -O - http://127.0.0.1:8333/
curl.exe -i http://127.0.0.1:8333/
```
---
```Bash
# Chạy smoke test bên trong mạng container
docker exec object-storage curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8333/
```
---
```Bash
# 1. Tắt tạm thời tính năng check online của BuildKit trong phiên PowerShell này
$env:DOCKER_BUILDKIT=0

# 2. Chạy lệnh build offline
docker compose --profile object_storage build
```
---
```bash
# Khởi động lại
docker compose --profile object_storage up -d
docker compose --profile object_storage ps

# kiểm tra khóa
docker exec object-storage cat /etc/object_storage/s3.json
```