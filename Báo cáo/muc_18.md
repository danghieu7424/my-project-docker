- OS-01: Đây là mức Minimum Viable Engine dành cho môi trường phát triển (Dev/Lab cục bộ).
- OS-02: Đây là tiêu chuẩn Vận hành Enterprise v1.1 để đưa vào sản xuất (Production).

| Tiêu chí | OS-01 (Engine Cơ Bản) | OS-02 (HA & Sao Lưu Enterprise) |
| :---: | :--- | :--- |
| Mục tiêu chính | Khởi tạo engine từ source, build offline, smoke test S3 API. | Chống chịu lỗi phần cứng (HA), phòng chống thảm họa mất dữ liệu (DR). | 
| Topology | 1 nút duy nhất (master + volume + filer + s3 gộp chung). | Phân tách rõ 2 cấp độ: object_storage (1 nút - ha: none) hoặc object_storage_ha (3 volume nodes). | 
| Healthcheck | curl kiểm tra mã 200/403 tại root / (dễ dính false-positive do phân quyền S3). | Endpoint /status hoặc thực thi lệnh thăm dò S3 định kỳ; đảm bảo tiến trình I/O thực sự khỏe. | 
| Bảo vệ Dữ liệu (Backup & Restore) | Chưa có cơ chế sao lưu; dữ liệu nằm cố định trong named volume. | Quy chuẩn hóa script backup.sh & restore.sh. Bắt buộc diễn tập khôi phục (Drill) bằng marker probe-before. | 
| Chỉ số RPO / RTO | Không cam kết. | Xác định rõ RPO (Recovery Point Objective, mục tiêu lab: ≤ 24h) và runbook khôi phục.
| Bảo mật Credential | Lưu trong .runtime/ (không commit git). | Nâng cao: Tách biệt tuyệt đối credential khỏi tarball backup dữ liệu (tránh rò rỉ khóa admin khi chuyển file backup). | 
| Tệp VERSION | Chỉ lưu git_ref, license, image, digest. | Bắt buộc bổ sung trường ha: none hoặc ha: 3-volume (minh bạch kiến trúc, cấm khai man HA). | 