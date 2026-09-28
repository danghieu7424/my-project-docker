# Xác định mô hình HA

## 1. 
- **Mô hình Single-node**: Sử dụng profile `object_storage` gồm 1 container duy nhất (chạy tích hợp master, volume, filer, s3 gateway).
- **Mô hình Cluster 3-volume**: Sử dụng profile `object_storage_ha` gồm tối thiểu 3 volume nodes riêng biệt, hỗ trợ nhân bản để khi mất đột ngột 1 volume node, các thao tác PutObject / GetObject.
- **Nguyên tắc liêm chính kiến trúc:** Nếu hệ thống chỉ chạy 1 container đơn lẻ, bắt buộc phải công khai minh bạch trong tệp metadata [VERSION](../object_storage/VERSION) là `ha: none` kèm chỉ số RPO mục tiêu
## 2. Cấu trúc, Thành phần chính và Cơ chế hoạt động của SeaweedFS

### A. Triết lý Kiến trúc: Kế thừa Facebook Haystack
SeaweedFS được thiết kế dựa trên bài báo nghiên cứu **Facebook Haystack Design**, giải quyết triệt để vấn đề "nghẽn cổ chai" (metadata overhead / inode exhaustion) của các hệ thống tệp POSIX truyền thống khi lưu trữ hàng triệu đến hàng tỷ tệp nhỏ:
*   **Tách rời Metadata và Storage:** Siêu dữ liệu đường dẫn tệp được tách riêng hoàn toàn khỏi dữ liệu nhị phân thực tế.
*   **Truy xuất đĩa tối ưu $O(1)$:** Dữ liệu thực tế được ghi nối tiếp (append-only) vào các tệp volume lớn (`.dat`) kèm tệp chỉ mục (`.idx`). Khi đọc một đối tượng, hệ thống chỉ cần đúng **1 lần đọc đĩa (1 disk seek)** dựa vào offset và size được lưu trên RAM.

---

### B. Bốn Thành phần Cốt lõi (Core Components)

1. **Master Server (`weed master`):**
   * Đóng vai trò bộ não điều phối: Quản lý danh sách các Volume Server và ánh xạ các Volume ID.
   * Cấp phát Volume ID mới khi ghi dữ liệu.
   * Khi triển khai HA nhiều Master, sử dụng thuật toán đồng thuận **Raft** để bầu Master Leader.
   * **Đặc tính quan trọng:** Master hoàn toàn nằm ngoài luồng đọc/ghi dữ liệu (Zero data-path bottleneck).

2. **Volume Server (`weed volume`):**
   * Chịu trách nhiệm lưu trữ dữ liệu nhị phân thực tế của object (dưới dạng các "Needles" nằm trong các file volume `.dat` kích thước tối đa 32GB).
   * Tiếp nhận lệnh đọc/ghi/xóa trực tiếp từ client mà không cần thông qua Master.
   * Hỗ trợ cơ chế nhân bản dữ liệu (Replication) giữa các server vật lý/container khác nhau.

3. **Filer Server (`weed filer`):**
   * Cung cấp lớp trừu tượng hóa hệ thống tệp phân tán (Directories, File Paths, Hierarchical namespace).
   * Lưu trữ cây thư mục và metadata của tệp vào các backend lưu trữ linh hoạt (LevelDB nhúng sẵn, RocksDB, Redis, PostgreSQL,...).
   * Là cầu nối cho các cổng truy cập cấp cao như S3 API, WebDAV, FUSE Mount.

4. **S3 Gateway (`weed s3`):**
   * Đóng gói và chuyển đổi API theo chuẩn **Amazon S3 RESTful API** (hỗ trợ `PutObject`, `GetObject`, `HeadObject`, `DeleteObject`, `ListObjectsV2`, `Multipart Upload`).
   * Thực thi xác thực chữ ký số **AWS Signature v4** thông qua tệp cấu hình tài khoản `s3.json`.
   * Giao tiếp trực tiếp với Filer và Volume Server để xử lý I/O.

---

### C. Chế độ Tích hợp Trong Dự Án Hiện Tại (`weed server`)

Trong môi trường Lab / Single-node (`ha: none`), SeaweedFS hỗ trợ lệnh gộp `weed server`:
* **Cơ chế:** Gộp chung cả 4 vai trò (**Master + Volume + Filer + S3**) vào trong **một tiến trình (single process) duy nhất**.
* **Ưu điểm:** Khởi động cực nhanh (< 2 giây), chiếm dụng tài nguyên cực thấp (~30-50MB RAM), toàn bộ dữ liệu metadata và volume đều tập trung tại named volume `/data`.

---

### D. Cơ chế Hoạt động & Nhân bản (Replication in HA)

* **Cơ chế ghi (Write Flow):** Client gửi `PutObject` tới S3 Gateway $\rightarrow$ S3 chuyển tới Filer $\rightarrow$ Filer hỏi Master vị trí Volume còn trống $\rightarrow$ Dữ liệu được ghi thẳng vào tệp `.dat` của Volume Server và cập nhật vị trí vào `.idx` $\rightarrow$ Trả về `200 OK`.
* **Cơ chế xóa (Delete Flow):** Đánh dấu xóa logic (tombstone) trong file chỉ mục `.idx`. Khi lượng dữ liệu rác vượt ngưỡng, SeaweedFS kích hoạt tiến trình nén chân không (Vacuum) để thu hồi dung lượng đĩa trống.
* **Cơ chế nhân bản HA (Replication Code):** SeaweedFS định nghĩa mức độ nhân bản bằng mã 3 chữ số `xyz`:
  * `x`: Số bản sao ở Data Center khác nhau.
  * `y`: Số bản sao ở Rack/Tủ mạng khác nhau.
  * `z`: Số bản sao ở Server khác nhau trên cùng Rack.
  *(Ví dụ: `001` sao chép sang 1 volume server khác trong cùng cụm, đảm bảo mất 1 node dữ liệu vẫn còn nguyên).*
