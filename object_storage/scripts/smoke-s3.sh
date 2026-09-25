#!/usr/bin/env bash
set -euo pipefail

# Tự động nạp cặp khóa runtime nếu tồn tại
if [ -f ".runtime/object_storage/credentials.env" ]; then
  set -a
  source .runtime/object_storage/credentials.env
  set +a
fi


ENDPOINT="${S3_ENDPOINT:-http://127.0.0.1:8333}"
BUCKET="objects"
TEST_FILE="probe.txt"
CONTENT="ping_test_payload_$(date +%s)"

export AWS_ACCESS_KEY_ID="${STORAGE_ADMIN_KEY:-STORAGE_ADMIN_KEY}"
export AWS_SECRET_ACCESS_KEY="${STORAGE_ADMIN_SECRET:-STORAGE_ADMIN_SECRET}"
export AWS_DEFAULT_REGION="us-east-1"

echo "=== 1. Tạo bucket '$BUCKET' ==="
aws --endpoint-url "$ENDPOINT" s3 mb "s3://$BUCKET" || true

echo "=== 2. PutObject ==="
echo "$CONTENT" | aws --endpoint-url "$ENDPOINT" s3 cp - "s3://$BUCKET/$TEST_FILE"

echo "=== 3. ListObjectsV2 ==="
aws --endpoint-url "$ENDPOINT" s3 ls "s3://$BUCKET/"

echo "=== 4. GetObject ==="
RETRIEVED=$(aws --endpoint-url "$ENDPOINT" s3 cp "s3://$BUCKET/$TEST_FILE" -)
if [ "$RETRIEVED" != "$CONTENT" ]; then
  echo "Lỗi: Dữ liệu tải về không khớp!"
  exit 1
fi
echo "Nội dung xác minh: $RETRIEVED"

echo "=== 5. DeleteObject ==="
aws --endpoint-url "$ENDPOINT" s3 rm "s3://$BUCKET/$TEST_FILE"

echo "SMOKE TEST THÀNH CÔNG (Mã thoát 0)"
exit 0