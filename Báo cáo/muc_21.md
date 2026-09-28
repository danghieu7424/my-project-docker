# Backup

- Tạo tệp [backup.sh](../object_storage/scripts/backup.sh).

- chạy lệnh:
```Bash
& "C:\Program Files\Git\bin\bash.exe" object_storage/scripts/backup.sh

==========================================================
BẮT ĐẦU SAO LƯU OBJECT STORAGE ENGINE (OS-02)
Thời gian: Tue, Sep 29, 2026  1:28:39 AM
Tệp đích: .runtime/object_storage/backups/object_storage_backup_20260929_012839.tar.gz
==========================================================
--> 1. Tạo snapshot nén dữ liệu từ /data...
--> 2. Trích xuất file backup ra host...
[+] copy 1/1
 ✔ object-storage Copied object-storage:/tmp/backup.tar.gz to .runtime/object_storage/backups/object_storage_backup_20260929_012839.tar.gz   0.1s
--> 3. Đối soát bảo mật: Đảm bảo không chứa credentials/s3.json...
✔ Xác thực an toàn: Bản sao lưu sạch 100%, không chứa khóa quản trị.
==========================================================
✔ SAO LƯU HOÀN TẤT THÀNH CÔNG
File: .runtime/object_storage/backups/object_storage_backup_20260929_012839.tar.gz
Kích thước: 18K
==========================================================
```

- Kiểm tra file backup:
```PowerShell
Get-ChildItem .runtime\object_storage\backups\


    Directory: D:\all_projects\Works\my-project\.runtime\object_storage\backups


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         9/29/2026   1:28 AM          17948 object_storage_backup_20260929_012839.tar.gz
```