#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-}
BACKUP_DIR="$(pwd)/backup_data"
IMAGE="object-storage:3.59"

if [ "$ACTION" == "backup" ]; then
    echo "=== Bắt đầu backup dữ liệu S3 ==="
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="s3_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Dùng chính image object-storage (chứa tar) để nén thư mục /data
    docker run --rm --volumes-from object-storage -v "$BACKUP_DIR":/backup "$IMAGE" sh -c "tar czf /backup/$BACKUP_FILE /data"
    
    echo "=== Backup thành công: $BACKUP_DIR/$BACKUP_FILE ==="

elif [ "$ACTION" == "restore" ]; then
    FILE=${2:-}
    if [ -z "$FILE" ]; then
        echo "Lỗi: Cần chỉ định file backup để restore."
        echo "Ví dụ: $0 restore backup_data/s3_backup.tar.gz"
        exit 1
    fi
    
    echo "=== Bắt đầu restore từ $FILE ==="
    # Xoá data hiện tại (nếu cần clean trước)
    # docker run --rm --volumes-from object-storage "$IMAGE" sh -c "rm -rf /data/*"
    
    # Giải nén đè lên /data
    docker run --rm --volumes-from object-storage -v "$(cd $(dirname $FILE) && pwd)":/backup "$IMAGE" sh -c "tar xzf /backup/$(basename $FILE) -C /"
    
    echo "=== Restore hoàn tất. Đang khởi động lại container... ==="
    docker restart object-storage
    echo "=== Đã khôi phục dữ liệu thành công ==="

else
    echo "Usage: $0 [backup | restore <file>]"
    exit 1
fi
