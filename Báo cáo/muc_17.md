

| STT | Tiêu chí nghiệm thu (Đề bài) | Kết quả thực tế trên Terminal |
|:---:|:---|:---|
| **1** | [**Pin Digest & Build Offline**](#1-pin-digest--build-offline) | `docker inspect` trích xuất chính xác `sha256:06b9f8ed2fdeb...` và đã cập nhật vào [object_storage/VERSION](./../object_storage/VERSION). |
| **2** | [**Bật Profile & Smoke Test**](#2-bật-profile--smoke-test) | Container đạt trạng thái `Up (healthy)`. Script [scripts/smoke-s3.sh](./..//object_storage/scripts/smoke-s3.sh) hoàn thành trọn vẹn cả 5 thao tác (Put + Metadata, HeadObject đối soát metadata, GetObject đối soát nội dung, List theo prefix, DeleteObject) với **Mã thoát 0**. |
| **3** | [**Tắt Profile (Isolation)**](#3-tắt-profile-isolation) | Khi chạy `docker compose up -d` thông thường, hệ thống phản hồi `no service selected` và `docker compose ps` hoàn toàn trống rỗng (không tự ý kích hoạt engine). |
| **4** | **An Toàn Thông Tin & Git Hygiene** | Các tệp credentials nhạy cảm nằm trọn trong `.runtime/` và đã được `.gitignore` bảo vệ. |

---
---

# 1. Pin Digest & Build Offline
```Bash
>> docker inspect --format='{{.Id}}' object-storage:3.59
sha256:06b9f8ed2fdeb672046948fc51b9e6c750c733adbc55e7ac79977848c2e8a968
```

# 2. Bật Profile & Smoke Test
```Bash
>>  docker compose --profile object_storage build
...
[+] build 1/1
 ✔ Image object-storage:3.59 Built 
```
```Bash
>> docker compose --profile object_storage up -d
[+] up 2/2
 ✔ Network my-project_default Created                                                                                                            0.0s
 ✔ Container object-storage   Started  
```
```Bash
>> docker compose --profile object_storage ps
NAME             IMAGE                 COMMAND                  SERVICE          CREATED              STATUS                        PORTS
object-storage   object-storage:3.59   "/usr/bin/weed serve…"   object_storage   About a minute ago   Up About a minute (healthy)   127.0.0.1:8333->8333/tcp
```

```Bash
>> bash object_storage/scripts/smoke-s3.sh
==========================================================
BẮT ĐẦU SMOKE TEST NĂNG LỰC S3 TỐI THIỂU
Endpoint: http://127.0.0.1:8333 | Bucket: objects
==========================================================
--> 1. Tạo bucket 'objects' (nếu chưa có)...
make_bucket failed: s3://objects An error occurred (BucketAlreadyExists) when calling the CreateBucket operation: The requested bucket name is not available. The bucket name can not be an existing collection, and the bucket namespace is shared by all users of the system. Please select a different name and try again.
--> 2. PutObject (kèm metadata: custom-meta=meta-val-1790445678)...
--> 3. HeadObject xác minh sự tồn tại & Metadata...
{
    "AcceptRanges": "bytes",
    "LastModified": "2026-09-26T18:01:19+00:00",
    "ContentLength": 29,
    "ETag": "\"ec7c81a5259a3ccf738b62d862658246\"",
    "ContentDisposition": "inline; filename=\"probe.txt\"",
    "ContentType": "text/plain; charset=utf-8",
    "Metadata": {
        "custom-meta": "meta-val-1790445678"
    }
}
✔ Metadata trả về nguyên giá trị đã gửi: meta-val-1790445678
--> 4. GetObject xác minh nội dung...
✔ Nội dung Get khớp 100% nội dung Put: ping_test_payload_1790445678
--> 5. List theo prefix 'probe'...
2026-09-27 01:01:19         29 probe.txt
✔ Thấy key 'probe.txt' theo prefix trước khi xóa
--> 6. DeleteObject...
delete: s3://objects/probe.txt
✔ Đã xóa 'probe.txt' thành công
==========================================================
✔ SMOKE TEST HOÀN TẤT THÀNH CÔNG (Mã thoát 0)
==========================================================
```

# 3. Tắt Profile (Isolation)
```Bash
>> docker compose --profile object_storage down
[+] down 2/2
 ✔ Container object-storage   Removed                                                                                                                                                       3.3s
 ✔ Network my-project_default Removed  
```

```Bash
>> docker compose --profile object_storage down
[+] down 2/2
 ✔ Container object-storage   Removed                                                                                                                                                       3.3s
 ✔ Network my-project_default Removed  
```

```Bash
>> docker compose ps
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```