<#
.SYNOPSIS
    Publishes a new release with the Dual Asset Upload Standard (versioned APK + VelocityDrive-latest.apk).
.DESCRIPTION
    Ensures that both the versioned APK and VelocityDrive-latest.apk are uploaded to the GitHub release,
    enabling the permanent direct download link:
    https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest/download/VelocityDrive-latest.apk
.EXAMPLE
    .\scripts\publish-release.ps1 -Tag "v5.1.42" -Title "Velocity Drive Alpha v5.1.42 (Build 42)" -ApkPath "VelocityDrive-v5.1-alpha-bv42.apk"
    .\scripts\publish-release.ps1 # Automatically detects latest APK in repository root
#>
param(
    [string]$Tag,

    [string]$Title,

    [string]$ApkPath,

    [string]$NotesPath,

    [string]$Repo = "fg2gstudio/Velocity_Drive_Releases"
)

$ErrorActionPreference = "Stop"

# Auto-locate latest APK if not specified
if (-not $ApkPath) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $rootDir = Split-Path -Parent $scriptDir
    $detectedApk = Get-ChildItem -Path $rootDir -Filter "VelocityDrive*.apk" |
        Where-Object { $_.Name -ne "VelocityDrive-latest.apk" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($detectedApk) {
        $ApkPath = $detectedApk.FullName
        Write-Host "Auto-detected APK: $($detectedApk.Name)" -ForegroundColor Cyan
    } else {
        Write-Error "No versioned APK found in repository root. Please specify -ApkPath."
    }
}

if (-not (Test-Path $ApkPath)) {
    Write-Error "APK file not found: $ApkPath"
}

$apkFilename = Split-Path -Leaf $ApkPath

# Auto-detect Tag and Title if not specified
if (-not $Tag) {
    if ($apkFilename -match "v?(\d+)[._](\d+).*?bv(\d+)") {
        $Tag = "v$($Matches[1]).$($Matches[2]).$($Matches[3])"
    } elseif ($apkFilename -match "v?(\d+\.\d+\.\d+)") {
        $Tag = "v$($Matches[1])"
    } else {
        $Tag = "v5.1.42"
    }
    Write-Host "Auto-detected Tag: $Tag" -ForegroundColor Cyan
}

if (-not $Title) {
    if ($Tag -match "v(\d+\.\d+)\.(\d+)") {
        $Title = "Velocity Drive Alpha $Tag (Build $($Matches[2]))"
    } else {
        $Title = "Velocity Drive $Tag"
    }
    Write-Host "Auto-detected Title: $Title" -ForegroundColor Cyan
}

# 1. Calculate SHA-256 and File Size
$hash = (Get-FileHash -Algorithm SHA256 $ApkPath).Hash.ToLowerInvariant()
$fileItem = Get-Item $ApkPath
$sizeBytes = $fileItem.Length
$sizeMB = [math]::Round($sizeBytes / 1000000, 0)
Write-Host "SHA-256 Checksum: $hash" -ForegroundColor Cyan
Write-Host "File Size: ~$sizeMB MB ($sizeBytes bytes)" -ForegroundColor Cyan

# 2. Dual Asset Standard: Create VelocityDrive-latest.apk copy
$latestApkPath = Join-Path (Split-Path -Parent (Resolve-Path $ApkPath)) "VelocityDrive-latest.apk"
Write-Host "Ensuring dual asset copy: $latestApkPath..." -ForegroundColor Cyan
if ((Resolve-Path $ApkPath).Path -ne (Resolve-Path $latestApkPath -ErrorAction SilentlyContinue).Path) {
    Copy-Item -Path $ApkPath -Destination $latestApkPath -Force
}

# 3. Locate GitHub CLI and ensure credentials
$gh = "gh"
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    if (Test-Path "$env:LOCALAPPDATA\Programs\gh\gh.exe") {
        $gh = "$env:LOCALAPPDATA\Programs\gh\gh.exe"
    } else {
        Write-Error "GitHub CLI (gh) not found in PATH or AppData."
    }
}

if (-not $env:GH_TOKEN -and -not $env:GITHUB_TOKEN) {
    try {
        $cred = "protocol=https`nhost=github.com" | git credential fill 2>$null
        $tokenLine = ($cred | Select-String "password=")
        if ($tokenLine) {
            $env:GH_TOKEN = $tokenLine.Line.Replace("password=", "").Trim()
        }
    } catch {}
}

# 4. Prepare Release Notes if not provided
$cleanupNotes = $false
if (-not $NotesPath -or -not (Test-Path $NotesPath)) {
    $bt = [char]96
    $defaultNotes = @"
Official $Title release for Android devices.

### Downloads:
- **Direct Download (Latest Link):** [VelocityDrive-latest.apk](https://github.com/$Repo/releases/latest/download/VelocityDrive-latest.apk)
- **Versioned Build:** [$apkFilename](https://github.com/$Repo/releases/download/$Tag/$apkFilename)

### Package Details:
- **Primary Binary:** $apkFilename
- **Permanent Latest Asset:** VelocityDrive-latest.apk
- **Target Platform:** Android 8.0+ (ARM64-v8a)
- **File Size:** ~$sizeMB MB (${bt}$sizeBytes${bt} bytes)
- **SHA-256 Checksum:** ${bt}$hash${bt}

### Installation:
1. Download ${bt}$apkFilename${bt} or ${bt}VelocityDrive-latest.apk${bt} to your Android device.
2. In your device settings, enable **Install unknown apps** for your browser or file manager.
3. Open the downloaded ${bt}.apk${bt} file and tap **Install**.
4. Launch Velocity Drive.
"@
    $NotesPath = Join-Path $env:TEMP "release_notes_$Tag.md"
    [System.IO.File]::WriteAllText($NotesPath, $defaultNotes, [System.Text.Encoding]::UTF8)
    $cleanupNotes = $true
}

# 5. Check if release already exists
$existingReleases = try { & $gh release list --repo $Repo --limit 100 2>$null } catch { @() }
$releaseExists = ($existingReleases | Where-Object { $_ -match "\b$Tag\b" })

if ($releaseExists) {
    Write-Host "Release $Tag already exists. Uploading dual assets with --clobber..." -ForegroundColor Yellow
    & $gh release upload $Tag $ApkPath $latestApkPath --clobber --repo $Repo
} else {
    Write-Host "Creating release $Tag with dual assets..." -ForegroundColor Green
    & $gh release create $Tag $ApkPath $latestApkPath --title $Title --notes-file $NotesPath --repo $Repo --latest
}

if ($cleanupNotes -and (Test-Path $NotesPath)) {
    Remove-Item $NotesPath -Force
}

Write-Host "Release $Tag published successfully with dual assets!" -ForegroundColor Green
Write-Host "Direct latest download URL:" -ForegroundColor Cyan
Write-Host "https://github.com/$Repo/releases/latest/download/VelocityDrive-latest.apk"
