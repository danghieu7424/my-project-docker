# Sinh khóa quản trị lúc init

## 1. Cấu trúc.

- Sinh một Access Key và một Secret mới, ngẫu nhiên.
    - Trong file [docker-compose.yml](../docker-compose.yml). không hard-code key.
- Ghi vào .runtime/object_storage/ (ví dụ credentials.env và s3.json đã điền khóa). Engine chỉ đọc file đó khi chạy.
    - Sinh khóa ngẫu nhiên qua file Script: [init.ps1](../object_storage/scripts/init.ps1). Và lưu tại [.runtime/object_storage/](../.runtime/object_storage/)
        - [credentials.env](.runtime/object_storage/credentials.env): Dùng cho các client S3 hoặc test script [smoke-s3.sh](../object_storage/scripts/smoke-s3.sh) nạp làm biến môi trường.
        - [s3.json](.runtime/object_storage/s3.json): Chứa cấu hình danh tính (internal-admin) kèm toàn quyền S3 (Read, Write, List, Tagging, Admin).

- SeaweedFS dùng cặp này để kiểm SigV4.
    - Container SeaweedFS chỉ mount file này ở chế độ chỉ đọc (:ro) tại /etc/object_storage/s3.json. [docker-compose.yml](../docker-compose.yml#L22)
    - Khi client gửi request S3, SeaweedFS sử dụng cặp khóa này để giải mã và kiểm tra chữ ký số AWS Signature v4 (SigV4). Nếu khớp chữ ký thì cho phép thực thi, nếu sai thì trả về 403 AccessDenied.

- Toàn bộ thư mục `.runtime/` nằm trong [.gitignore](../.gitignore), không bao giờ commit lên git.

## 2. Quy trình.

- Chạy Script:
```Bash
>> powershell -ExecutionPolicy Bypass -File object_storage/scripts/init.ps1

[INIT] Da tao credentials.env moi.
[INIT] Da tao .runtime/object_storage/s3.json thanh cong!
```

- Kiểm tra 2 file sinh ra trong .runtime/object_storage/
```PowerShell
>> Get-ChildItem .runtime\object_storage\


    Directory: D:\all_projects\Works\my-project\.runtime\object_storage


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         9/29/2026   1:28 AM                backups
-a----         9/29/2026   1:50 AM            106 credentials.env
-a----         9/29/2026   1:50 AM            310 s3.json
```

- Kiểm tra s3.json:
```PowerShell
>> Get-Content .runtime\object_storage\s3.json

{
  "identities": [
    {
      "name": "internal-admin",
      "credentials": [
        {
          "accessKey": "173CD755B9F244D685C9",
          "secretKey": "b3e8d9966fcd4cdea2fd5d469f0055cde604954a"
        }
      ],
      "actions": ["Read", "Write", "List", "Tagging", "Admin"]
    }
  ]
}
```