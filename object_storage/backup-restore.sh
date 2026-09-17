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
    # Lưu ý: Cần override entrypoint vì mặc định là "weed"
    docker run --rm --volumes-from object-storage -v "$BACKUP_DIR":/backup --entrypoint sh "$IMAGE" -c "tar czf /backup/$BACKUP_FILE /data"
    
    echo "=== Backup thành công: $BACKUP_DIR/$BACKUP_FILE ==="

elif [ "$ACTION" == "restore" ]; then
    FILE=${2:-}
    if [ -z "$FILE" ]; then
        echo "Lỗi: Cần chỉ định file backup để restore."
        echo "Ví dụ: $0 restore backup_data/s3_backup.tar.gz"
        exit 1
    fi
    
    echo "=== Bắt đầu restore từ $FILE ==="
    # STOP container đang chạy để giải phóng Lock của LevelDB trước khi restore
    echo "Đang tạm dừng hệ thống để an toàn khôi phục..."
    docker stop object-storage
    
    # Giải nén đè lên /data (nhớ override entrypoint)
    docker run --rm --volumes-from object-storage -v "$(cd $(dirname $FILE) && pwd)":/backup --entrypoint sh "$IMAGE" -c "rm -rf /data/* && tar xzf /backup/$(basename $FILE) -C /"
    
    echo "=== Restore hoàn tất. Đang khởi động lại container... ==="
    docker start object-storage
    echo "=== Đã khôi phục dữ liệu thành công ==="

else
    echo "Usage: $0 [backup | restore <file>]"
    exit 1
fi
