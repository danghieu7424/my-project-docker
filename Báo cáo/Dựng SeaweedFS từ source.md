cd  object_storage
Remove-Item -Recurse -Force src\.git
git clone --depth 1 --branch 3.59 https://github.com/seaweedfs/seaweedfs.git src