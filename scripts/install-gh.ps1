$downloadUrl = "https://github.com/cli/cli/releases/latest/download/gh_2.64.0_windows_amd64.zip"
$zipPath = "$env:TEMP\gh.zip"
$extractPath = "$env:LOCALAPPDATA\Programs\gh"

Write-Host "⬇️ 下载 GitHub CLI..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

Write-Host "📦 解压到 $extractPath ..." -ForegroundColor Cyan
if (Test-Path $extractPath) { Remove-Item -Recurse -Force $extractPath }
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath)

# gh.exe 在 bin\gh.exe
$ghPath = Join-Path $extractPath "bin\gh.exe"
if (-not (Test-Path $ghPath)) {
    # 也可能是直接在根目录
    $ghPath = Join-Path $extractPath "gh.exe"
}

Write-Host "✅ gh 已安装: $ghPath" -ForegroundColor Green

# 加到 PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$binDir = Split-Path $ghPath -Parent
if ($currentPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binDir", "User")
    Write-Host "✅ 已添加到用户 PATH" -ForegroundColor Green
}

Remove-Item $zipPath -Force
Write-Host "`n🔐 运行 gh auth login 进行 GitHub 登录" -ForegroundColor Yellow
