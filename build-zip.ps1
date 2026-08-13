# Regenerates the release zip (dsh-web-ui-portable.zip) from the repo files.
# Usage: powershell -ExecutionPolicy Bypass -File build-zip.ps1
$here = $PSScriptRoot
$exclude = @('README.md', 'README.zh-CN.md', 'LICENSE', 'build-zip.ps1', '.gitignore', '.git', '.zip-stage', 'dsh-web-ui-portable.zip')
$stage = Join-Path $here '.zip-stage'
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Get-ChildItem $here -Force |
    Where-Object { $exclude -notcontains $_.Name } |
    Copy-Item -Destination $stage -Recurse -Force
$out = Join-Path $here 'dsh-web-ui-portable.zip'
Remove-Item $out -Force -ErrorAction SilentlyContinue
Compress-Archive -Path "$stage\*" -DestinationPath $out -CompressionLevel Optimal
Remove-Item $stage -Recurse -Force
Write-Host "Built: $out"
