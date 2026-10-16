<#
.SYNOPSIS
    Publishes a new release with the Dual Asset Upload Standard (versioned APK + VelocityDrive-latest.apk).
.DESCRIPTION
    Ensures that both the versioned APK and VelocityDrive-latest.apk are uploaded to the GitHub release,
    enabling the permanent direct download link:
    https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest/download/VelocityDrive-latest.apk
.EXAMPLE
    .\scripts\publish-release.ps1 -Tag "v5.0.41" -Title "Velocity Drive Alpha v5.0.41 (Build 41)" -ApkPath "VelocityDrive_v5_0-alpha_bv41.apk"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [string]$NotesPath,

    [string]$Repo = "fg2gstudio/Velocity_Drive_Releases"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ApkPath)) {
    Write-Error "APK file not found: $ApkPath"
}

# 1. Calculate SHA-256
$hash = (Get-FileHash -Algorithm SHA256 $ApkPath).Hash.ToLowerInvariant()
Write-Host "SHA-256 Checksum: $hash" -ForegroundColor Cyan

# 2. Dual Asset Standard: Create VelocityDrive-latest.apk copy
$latestApkPath = Join-Path (Split-Path -Parent (Resolve-Path $ApkPath)) "VelocityDrive-latest.apk"
Write-Host "Ensuring dual asset copy: $latestApkPath..." -ForegroundColor Cyan
if ((Resolve-Path $ApkPath).Path -ne (Resolve-Path $latestApkPath -ErrorAction SilentlyContinue).Path) {
    Copy-Item -Path $ApkPath -Destination $latestApkPath -Force
}

# 3. Locate GitHub CLI
$gh = "gh"
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    if (Test-Path "$env:LOCALAPPDATA\Programs\gh\gh.exe") {
        $gh = "$env:LOCALAPPDATA\Programs\gh\gh.exe"
    } else {
        Write-Error "GitHub CLI (gh) not found in PATH or AppData."
    }
}

# 4. Prepare Release Notes if not provided
$cleanupNotes = $false
if (-not $NotesPath -or -not (Test-Path $NotesPath)) {
    $apkFilename = Split-Path -Leaf $ApkPath
    $defaultNotes = @"
Official $Title for Android devices.

### Package Details:
- **File:** ``$apkFilename``
- **Latest Link Asset:** ``VelocityDrive-latest.apk``
- **Target Platform:** Android 8.0+ (ARM64)
- **SHA-256:** ``$hash``

### Installation:
1. Download ``$apkFilename`` or ``VelocityDrive-latest.apk`` to your Android device.
2. Allow installation from unknown sources in settings.
3. Install and run.
"@
    $NotesPath = Join-Path $env:TEMP "release_notes_$Tag.md"
    [System.IO.File]::WriteAllText($NotesPath, $defaultNotes, [System.Text.Encoding]::UTF8)
    $cleanupNotes = $true
}

# 5. Check if release already exists
$releaseExists = & $gh release view $Tag --repo $Repo 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Release $Tag already exists. Uploading dual assets with --clobber..." -ForegroundColor Yellow
    & $gh release upload $Tag $ApkPath $latestApkPath --clobber --repo $Repo
} else {
    Write-Host "Creating release $Tag with dual assets..." -ForegroundColor Green
    & $gh release create $Tag $ApkPath $latestApkPath --title $Title --notes-file $NotesPath --repo $Repo
}

if ($cleanupNotes -and (Test-Path $NotesPath)) {
    Remove-Item $NotesPath -Force
}

Write-Host "Release $Tag published successfully with dual assets!" -ForegroundColor Green
Write-Host "Direct latest download URL:" -ForegroundColor Cyan
Write-Host "https://github.com/$Repo/releases/latest/download/VelocityDrive-latest.apk"
