cd  object_storage
Remove-Item -Recurse -Force src\.git
git clone --depth 1 --branch 3.59 https://github.com/seaweedfs/seaweedfs.git src
Copy-Item src\LICENSE -Destination LICENSE -Force
cd ..
docker compose --profile object_storage build --no-cache
docker images object-storage:3.59

docker compose --profile object_storage down
docker compose --profile object_storage build
docker compose --profile object_storage up -d
docker compose --profile object_storage ps

docker exec object-storage wget -S -O - http://127.0.0.1:8333/
curl.exe -i http://127.0.0.1:8333/