[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$project = $root
$pubspec = Get-Content -Raw -LiteralPath (Join-Path $project 'pubspec.yaml')
$version = [regex]::Match($pubspec, '(?m)^version:\s*([^+\r\n]+)').Groups[1].Value
$releaseDir = Join-Path $project 'build\windows\x64\runner\Release'
$outputDir = Join-Path $root 'release'
$archive = Join-Path $outputDir "DDL_out_v$version-windows-x64-portable.zip"

Push-Location $project
try {
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'Flutter Windows build failed.' }
} finally {
    Pop-Location
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
Compress-Archive -Path (Join-Path $releaseDir '*') -DestinationPath $archive
Write-Host "Created $archive"
