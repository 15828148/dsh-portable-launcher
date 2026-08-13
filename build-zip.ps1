# Regenerates the release zip (DSH-Web-UI-便携版.zip) from the repo files.
# Usage: pwsh -File build-zip.ps1
$here = $PSScriptRoot
$files = @('dsh-web.bat', 'setup.bat', 'deepseek.ico', '使用说明.txt')
$stage = Join-Path $here '.zip-stage'
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $stage -Force | Out-Null
foreach ($f in $files) {
    Copy-Item (Join-Path $here $f) (Join-Path $stage $f) -Force
}
$out = Join-Path $here 'DSH-Web-UI-便携版.zip'
Remove-Item $out -Force -ErrorAction SilentlyContinue
Compress-Archive -Path "$stage\*" -DestinationPath $out -CompressionLevel Optimal
Remove-Item $stage -Recurse -Force
Write-Host "Built: $out"
