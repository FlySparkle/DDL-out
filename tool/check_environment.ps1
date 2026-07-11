[CmdletBinding()]
param(
    [switch]$SkipAndroid,
    [switch]$ShowVersions
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Test-Command {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string]$Label,
        [switch]$Required
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        Write-Host "[OK]   $Label - $($command.Source)" -ForegroundColor Green
        return $true
    }

    $message = "$Label ($Name) was not found in PATH."
    if ($Required) {
        $failures.Add($message)
        Write-Host "[FAIL] $message" -ForegroundColor Red
    } else {
        $warnings.Add($message)
        Write-Host "[WARN] $message" -ForegroundColor Yellow
    }
    return $false
}

Write-Host 'DDL out! development environment' -ForegroundColor Cyan

$hasGit = Test-Command -Name 'git' -Label 'Git' -Required
$hasFlutter = Test-Command -Name 'flutter' -Label 'Flutter' -Required
$hasDart = Test-Command -Name 'dart' -Label 'Dart' -Required
Test-Command -Name 'code' -Label 'VS Code' | Out-Null

$vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path -LiteralPath $vswhere) {
    $nativeDesktop = & $vswhere -products * -requires Microsoft.VisualStudio.Workload.NativeDesktop -property installationPath
    if ($nativeDesktop) {
        Write-Host "[OK]   Visual Studio C++ desktop workload - $nativeDesktop" -ForegroundColor Green
    } else {
        $failures.Add('Visual Studio Desktop development with C++ workload is missing.')
        Write-Host '[FAIL] Visual Studio Desktop development with C++ workload is missing.' -ForegroundColor Red
    }
} else {
    $failures.Add('Visual Studio Installer and vswhere.exe were not found.')
    Write-Host '[FAIL] Visual Studio Installer and vswhere.exe were not found.' -ForegroundColor Red
}

if (-not $SkipAndroid -and $hasFlutter) {
    $flutterConfig = (& flutter config --list 2>&1) -join "`n"
    $jdkMatch = [regex]::Match($flutterConfig, '(?m)^\s*jdk-dir:\s*(.+)$')
    $sdkMatch = [regex]::Match($flutterConfig, '(?m)^\s*android-sdk:\s*(.+)$')

    $jdkPath = if ($jdkMatch.Success) { $jdkMatch.Groups[1].Value.Trim() } else { $null }
    if ($jdkPath -and (Test-Path -LiteralPath (Join-Path $jdkPath 'bin\java.exe'))) {
        Write-Host "[OK]   Flutter JDK - $jdkPath" -ForegroundColor Green
    } else {
        $failures.Add('Flutter is not configured with a valid JDK.')
        Write-Host '[FAIL] Flutter is not configured with a valid JDK.' -ForegroundColor Red
    }

    $sdkPath = if ($sdkMatch.Success) { $sdkMatch.Groups[1].Value.Trim() } else { $null }
    if ($sdkPath -and (Test-Path -LiteralPath (Join-Path $sdkPath 'platform-tools\adb.exe'))) {
        Write-Host "[OK]   Android SDK - $sdkPath" -ForegroundColor Green
    } else {
        $failures.Add('Flutter is not configured with a valid Android SDK.')
        Write-Host '[FAIL] Flutter is not configured with a valid Android SDK.' -ForegroundColor Red
    }
} else {
    Test-Command -Name 'java' -Label 'Java (Android check skipped)' | Out-Null
    Test-Command -Name 'adb' -Label 'Android platform tools (Android check skipped)' | Out-Null
}

if ($hasFlutter -and $ShowVersions) {
    Write-Host ''
    & flutter --version
}

Write-Host ''
if ($warnings.Count -gt 0) {
    Write-Host "Warnings: $($warnings.Count)" -ForegroundColor Yellow
}

if ($failures.Count -gt 0) {
    Write-Host "Required checks failed: $($failures.Count)" -ForegroundColor Red
    exit 1
}

Write-Host 'Required Windows and Android development checks passed.' -ForegroundColor Green
