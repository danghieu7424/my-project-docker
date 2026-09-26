#!/usr/bin/env bash
set -euo pipefail

# 1. Tự động đọc cặp khóa runtime
if [ -f ".runtime/object_storage/credentials.env" ]; then
  STORAGE_ADMIN_KEY=$(grep 'STORAGE_ADMIN_KEY=' .runtime/object_storage/credentials.env | cut -d= -f2 | tr -d '\r\n ')
  STORAGE_ADMIN_SECRET=$(grep 'STORAGE_ADMIN_SECRET=' .runtime/object_storage/credentials.env | cut -d= -f2 | tr -d '\r\n ')
fi

ENDPOINT="${S3_ENDPOINT:-http://127.0.0.1:8333}"
BUCKET="objects"
KEY="probe.txt"
PAYLOAD="ping_test_payload_$(date +%s)"
META_VAL="meta-val-$(date +%s)"

export AWS_ACCESS_KEY_ID="${STORAGE_ADMIN_KEY}"
export AWS_SECRET_ACCESS_KEY="${STORAGE_ADMIN_SECRET}"
export AWS_DEFAULT_REGION="us-east-1"

echo "=========================================================="
echo "BẮT ĐẦU SMOKE TEST NĂNG LỰC S3 TỐI THIỂU"
echo "Endpoint: $ENDPOINT | Bucket: $BUCKET"
echo "=========================================================="

# 0. Tạo bucket nếu chưa có
echo "--> 1. Tạo bucket '$BUCKET' (nếu chưa có)..."
aws --endpoint-url "$ENDPOINT" s3 mb "s3://$BUCKET" || true

# 1. PutObject kèm metadata x-amz-meta-custom
echo "--> 2. PutObject (kèm metadata: custom-meta=$META_VAL)..."
echo "$PAYLOAD" | aws --endpoint-url "$ENDPOINT" s3 cp - "s3://$BUCKET/$KEY" --metadata "custom-meta=$META_VAL"

# 2. HeadObject kiểm tra sự tồn tại và đọc lại metadata
echo "--> 3. HeadObject xác minh sự tồn tại & Metadata..."
HEAD_OUT=$(aws --endpoint-url "$ENDPOINT" s3api head-object --bucket "$BUCKET" --key "$KEY")
echo "$HEAD_OUT"
if echo "$HEAD_OUT" | grep -q "$META_VAL"; then
  echo "✔ Metadata trả về nguyên giá trị đã gửi: $META_VAL"
else
  echo "❌ Lỗi: Metadata không khớp hoặc không tìm thấy!"
  exit 1
fi

# 3. GetObject và đối chiếu nội dung
echo "--> 4. GetObject xác minh nội dung..."
GET_CONTENT=$(aws --endpoint-url "$ENDPOINT" s3 cp "s3://$BUCKET/$KEY" -)
if [ "$GET_CONTENT" == "$PAYLOAD" ]; then
  echo "✔ Nội dung Get khớp 100% nội dung Put: $GET_CONTENT"
else
  echo "❌ Lỗi: Nội dung Get không khớp nội dung Put!"
  exit 1
fi

# 4. ListObjectsV2 theo prefix
echo "--> 5. List theo prefix 'probe'..."
LIST_OUT=$(aws --endpoint-url "$ENDPOINT" s3 ls "s3://$BUCKET/probe")
echo "$LIST_OUT"
if echo "$LIST_OUT" | grep -q "$KEY"; then
  echo "✔ Thấy key '$KEY' theo prefix trước khi xóa"
else
  echo "❌ Lỗi: Không thấy key theo prefix!"
  exit 1
fi

# 5. DeleteObject
echo "--> 6. DeleteObject..."
aws --endpoint-url "$ENDPOINT" s3 rm "s3://$BUCKET/$KEY"
echo "✔ Đã xóa '$KEY' thành công"

echo "=========================================================="
echo "✔ SMOKE TEST HOÀN TẤT THÀNH CÔNG (Mã thoát 0)"
echo "=========================================================="
exit 0
