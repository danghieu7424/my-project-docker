
| STT | Tiêu chí nghiệm thu (Đề bài) | Kết quả thực tế trên Terminal của bạn |
|:---:|:---|:---|
| **1** | **Script exit 0** | Dòng cuối cùng in: `✔ SMOKE TEST HOÀN TẤT THÀNH CÔNG (Mã thoát 0)` |
| **2** | **Nội dung Get khớp nội dung Put** | `✔ Nội dung Get khớp 100% nội dung Put: ping_test_payload_1790443422` |
| **3** | **Head thấy object** | Lệnh `s3api head-object` trả về đầy đủ thông tin: `ETag`, `ContentLength: 29`, `ContentType: text/plain` |
| **4** | **List thấy key theo prefix trước khi xóa** | `✔ Thấy key 'probe.txt' theo prefix trước khi xóa` (`2026-09-27 00:23:44 29 probe.txt`) |
| **5** | **Metadata trả về nguyên giá trị đã gửi** | `✔ Metadata trả về nguyên giá trị đã gửi: meta-val-1790443422` |

---

```Bash
bash object_storage/scripts/smoke-s3.sh
>> 
==========================================================
BẮT ĐẦU SMOKE TEST NĂNG LỰC S3 TỐI THIỂU
Endpoint: http://127.0.0.1:8333 | Bucket: objects
==========================================================
--> 1. Tạo bucket 'objects' (nếu chưa có)...
make_bucket failed: s3://objects An error occurred (BucketAlreadyExists) when calling the CreateBucket operation: The requested bucket name is not available. The bucket name can not be an existing collection, and the bucket namespace is shared by all users of the system. Please select a different name and try again.
--> 2. PutObject (kèm metadata: custom-meta=meta-val-1790443422)...
--> 3. HeadObject xác minh sự tồn tại & Metadata...
{
    "AcceptRanges": "bytes",
    "LastModified": "2026-09-26T17:23:44+00:00",
    "ContentLength": 29,
    "ETag": "\"3af59aa09d8e5a6575436795ca671dd6\"",
    "ContentDisposition": "inline; filename=\"probe.txt\"",
    "ContentType": "text/plain; charset=utf-8",
    "Metadata": {
        "custom-meta": "meta-val-1790443422"
    }
}
✔ Metadata trả về nguyên giá trị đã gửi: meta-val-1790443422
--> 4. GetObject xác minh nội dung...
✔ Nội dung Get khớp 100% nội dung Put: ping_test_payload_1790443422
--> 5. List theo prefix 'probe'...
2026-09-27 00:23:44         29 probe.txt
✔ Thấy key 'probe.txt' theo prefix trước khi xóa
--> 6. DeleteObject...
delete: s3://objects/probe.txt
✔ Đã xóa 'probe.txt' thành công
==========================================================
✔ SMOKE TEST HOÀN TẤT THÀNH CÔNG (Mã thoát 0)
==========================================================
```