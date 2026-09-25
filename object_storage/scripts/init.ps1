# ========================================================
# Script: Tự động khởi tạo Credential S3 Runtime
# ========================================================
$runtimeDir = ".runtime/object_storage"
if (-not (Test-Path $runtimeDir)) {
    New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
}

# Nếu chưa có khóa thì tự sinh ngẫu nhiên
if (-not (Test-Path "$runtimeDir/credentials.env")) {
    $accessKey = [System.Guid]::NewGuid().ToString("N").Substring(0, 20).ToUpper()
    $secretKey = [System.Guid]::NewGuid().ToString("N") + [System.Guid]::NewGuid().ToString("N").Substring(0, 8)

    @"
STORAGE_ADMIN_KEY=$accessKey
STORAGE_ADMIN_SECRET=$secretKey
"@ | Set-Content -Path "$runtimeDir/credentials.env" -Encoding UTF8
    Write-Host "[INIT] Da tao credentials.env moi." -ForegroundColor Green
} else {
    $creds = Get-Content "$runtimeDir/credentials.env"
    $accessKey = ($creds[0] -split '=')[1].Trim()
    $secretKey = ($creds[1] -split '=')[1].Trim()
    Write-Host "[INIT] Su dung credentials.env hien tai." -ForegroundColor Yellow
}

# Tạo s3.json chuẩn UTF8 No-BOM để Linux container không bị crash
$jsonContent = @"
{
  "identities": [
    {
      "name": "internal-admin",
      "credentials": [
        {
          "accessKey": "$accessKey",
          "secretKey": "$secretKey"
        }
      ],
      "actions": ["Read", "Write", "List", "Tagging", "Admin"]
    }
  ]
}
"@
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$(Get-Location)/$runtimeDir/s3.json", $jsonContent, $utf8NoBom)
Write-Host "[INIT] Da tao $runtimeDir/s3.json thanh cong!" -ForegroundColor Green
