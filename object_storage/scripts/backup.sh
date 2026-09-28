#!/usr/bin/env bash
set -euo pipefail

export MSYS_NO_PATHCONV=1

# Thư mục lưu trữ bản backup (mặc định trong .runtime/object_storage/backups để không bị commit)
BACKUP_DIR="${1:-.runtime/object_storage/backups}"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILENAME="object_storage_backup_${TIMESTAMP}.tar.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"

echo "=========================================================="
echo "BẮT ĐẦU SAO LƯU OBJECT STORAGE ENGINE (OS-02)"
echo "Thời gian: $(date)"
echo "Tệp đích: $BACKUP_PATH"
echo "=========================================================="

# 1. Đảm bảo container đang chạy để trích xuất snapshot volume
if ! docker compose --profile object_storage ps | grep -q "object-storage"; then
    echo "❌ Lỗi: Container 'object-storage' không chạy. Vui lòng bật profile trước!"
    exit 1
fi

# 2. Đóng gói dữ liệu trong thư mục /data ra file tạm trong container
echo "--> 1. Tạo snapshot nén dữ liệu từ /data..."
docker compose --profile object_storage exec -T object_storage tar -czf /tmp/backup.tar.gz -C /data .

# 3. Copy bản nén từ container ra host
echo "--> 2. Trích xuất file backup ra host..."
docker compose --profile object_storage cp object_storage:/tmp/backup.tar.gz "$BACKUP_PATH"

# 4. Xóa file tạm trong container
docker compose --profile object_storage exec -T object_storage rm -f /tmp/backup.tar.gz

# 5. Đối soát bảo mật bắt buộc (OS-02 Mục 5.2)
echo "--> 3. Đối soát bảo mật: Đảm bảo không chứa credentials/s3.json..."
if tar -ztvf "$BACKUP_PATH" 2>/dev/null | grep -E 's3\.json|credentials|\.env'; then
    echo "❌ NGUY HIỂM: Phát hiện file nhạy cảm trong gói sao lưu!"
    rm -f "$BACKUP_PATH"
    exit 1
fi
echo "✔ Xác thực an toàn: Bản sao lưu sạch 100%, không chứa khóa quản trị."

# 6. Báo cáo dung lượng
FILESIZE=$(ls -lh "$BACKUP_PATH" | awk '{print $5}')
echo "=========================================================="
echo "✔ SAO LƯU HOÀN TẤT THÀNH CÔNG"
echo "File: $BACKUP_PATH"
echo "Kích thước: $FILESIZE"
echo "=========================================================="
