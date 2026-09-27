# Kiểm tra và sửa healthcheck S3
## 1. Bản chất và Phân tích nguyên nhân (Root Cause)
- Endpoint `:8333` của SeaweedFS là S3 API Gateway, mặc định yêu cầu xác thực bằng AWS Signature v4.
- Khi gửi request HTTP thông thường (không kèm chữ ký/token) tới endpoint root `http://127.0.0.1:8333/`, server trả về mã HTTP `403 Forbidden` (`AccessDenied`).
- Nếu chỉ coi mã `2xx` là healthy (ví dụ sử dụng `curl -f`), Docker sẽ đánh giá sai rằng tiến trình đã chết và liên tục restart container (restart loop).
- Thực tế, phản hồi `403` chứng minh Web Server và bộ định tuyến bảo mật S3 đang hoạt động bình thường. Do đó, cơ chế healthcheck bắt buộc phải chấp nhận cả mã `200` và `403`.
---
## 2. Kiểm tra Response thực tế của S3 Endpoint
### A. Kiểm tra phản hồi chi tiết (Headers & Body)
```bash
>> docker compose --profile object_storage exec object_storage curl -i http://127.0.0.1:8333/

HTTP/1.1 403 Forbidden
Accept-Ranges: bytes
Content-Length: 176
Content-Type: application/xml
Server: SeaweedFS S3
X-Amz-Request-Id: 1790528217545678800
<Error><Code>AccessDenied</Code><Message>Access Denied.</Message><Resource>/</Resource><RequestId>1790528217545649500</RequestId></Error>
```

### B. Kiểm tra mã trạng thái HTTP trả về
```Bash
>> docker compose --profile object_storage exec object_storage curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8333/

403
```

## 3. Cấu hình Healthcheck trong docker-compose.yml
```yaml
healthcheck:
    test: ["CMD-SHELL", "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8333/ | grep -E '200|403' || exit 1"]
```
=> Đổi theo tài liệu OS-02
```yaml
healthcheck:
    test: ["CMD-SHELL", "curl -sf -o /dev/null -w '%{http_code}' http://127.0.0.1:8333/status | grep -E '200|403' || curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8333/ | grep -E '200|403' || exit 1"]
```
### 4. Kết quả nghiệm thu thực tế
```Bash
>> docker compose --profile object_storage ps

NAME             IMAGE                 COMMAND                  SERVICE          CREATED          STATUS                    PORTS
object-storage   object-storage:3.59   "/usr/bin/weed serve…"   object_storage   41 seconds ago   Up 37 seconds (healthy)   127.0.0.1:8333->8333/tcp
```