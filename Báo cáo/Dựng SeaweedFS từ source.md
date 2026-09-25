cd  object_storage
Remove-Item -Recurse -Force src\.git
git clone --depth 1 --branch 3.59 https://github.com/seaweedfs/seaweedfs.git src
Copy-Item src\LICENSE -Destination LICENSE -Force
cd ..
docker compose --profile object_storage build --no-cache
docker images object-storage:3.59