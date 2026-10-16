# Velocity Drive — Android Releases

[![Direct Download Latest APK](https://img.shields.io/badge/Direct%20Download-Latest%20APK-0070F3?style=for-the-badge&logo=android&logoColor=white)](https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest/download/VelocityDrive-latest.apk)
[![GitHub Release](https://img.shields.io/github/v/release/fg2gstudio/Velocity_Drive_Releases?style=for-the-badge&logo=github&color=2ea44f)](https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest)

Official release distribution repository for **Velocity Drive**, developed by **FG2G Studio**.

---

## Downloads

Download the latest release build for Android:

- 🚀 **Direct Download (Permanent Latest):** [VelocityDrive-latest.apk](https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest/download/VelocityDrive-latest.apk)
  > *Always points to the newest Android release build without version-specific URL changes.*
- 📦 **Current Versioned Build (v5.0.41):** [VelocityDrive_v5_0-alpha_bv41.apk](https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/download/v5.0.41/VelocityDrive_v5_0-alpha_bv41.apk) (~313 MB)
- 📋 **All Releases:** [GitHub Releases Page](https://github.com/fg2gstudio/Velocity_Drive_Releases/releases)

---

## Dual Asset Standard

Every Velocity Drive release adheres to FG2G Studio's **Dual Asset Upload Standard**:
1. **Versioned Archive:** `VelocityDrive_v<version>-<channel>_bv<build>.apk` (e.g., `VelocityDrive_v5_0-alpha_bv41.apk`) for immutable archival and tracking.
2. **Permanent Latest Alias:** `VelocityDrive-latest.apk` attached directly to the release tagged as the **Latest release**.

This standard enables direct, permanent integration for automated download buttons, web portals, and Cloudflare Worker redirects via:
```text
https://github.com/fg2gstudio/Velocity_Drive_Releases/releases/latest/download/VelocityDrive-latest.apk
```

---

## Android Installation Guide
1. Download the `.apk` package to your Android device using the direct download link above.
2. In your device settings, enable **Install unknown apps** for your browser or file manager (Settings → Security & Privacy → Install unknown apps).
3. Open the downloaded `.apk` file and tap **Install**.
4. Launch Velocity Drive.

---

## Minimum System Specifications
- **Operating System:** Android 8.0 (Oreo) or higher (API level 26+)
- **Processor:** 64-bit ARM (ARM64-v8a)
- **Memory (RAM):** 3 GB RAM or higher
- **Graphics:** OpenGL ES 3.0 / Vulkan compatible GPU
- **Free Storage:** ~350 MB

---

## Package Verification
You can verify the package integrity using its SHA-256 checksum:
- **Windows (PowerShell):** `Get-FileHash -Algorithm SHA256 VelocityDrive_v5_0-alpha_bv41.apk`
- **Linux / macOS:** `sha256sum VelocityDrive_v5_0-alpha_bv41.apk`
- **Build 41 SHA-256:** `5658eae40bbfca8ce93cb9e5a4910ab9293a424fcb2742b9ce949fd48e7f8f73`
