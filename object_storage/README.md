# Object Storage Engine (Bundled)

Module cung cấp kho lưu trữ S3-native nội bộ cho môi trường greenfield.

## Thông Tin Thành Phần
- **Tên công khai:** `object_storage`
- **Loại:** Storage Engine (S3 API)
- **Port nội bộ:** `:8333` (mạng Docker Compose)
- **Adapter key nội bộ:** `seaweedfs`

## Nguồn Gốc & Giấy Phép (Attribution)
- **Upstream:** [SeaweedFS](https://github.com/seaweedfs/seaweedfs.git)
- **Phiên bản:** `3.59` (commit `27b34f37935fb3eddb9c7759acf397dbae20eb03`)
- **Giấy phép:** Apache License 2.0 (chi tiết xem tại tệp [LICENSE](./LICENSE))

## Kiểm Thử
Chạy smoke test S3:
```bash
bash scripts/smoke-s3.sh
```


---

#### 3. Kiểm tra file `registry.yml` ở thư mục gốc
Mở file [registry.yml](./../registry.yml) và đối chiếu:
```yaml
- name: object_storage
  type: storage
  license: Apache-2.0
  source_mode: vendor
  source_path: object_storage
  docker_image: object-storage:3.59
  compose_profile: object_storage
  capability: objects.engine
  status: pinned
```