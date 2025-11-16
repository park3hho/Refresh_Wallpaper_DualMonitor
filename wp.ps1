# =================================================================
# 1. Path Configuration
# =================================================================

# Folder containing Portrait images (ASSIGNED TO Monitor 2)
$PortraitFolder = "C:\Users\iwill\wallpaper\wallpapers\portrait"

# Folder containing Landscape images (ASSIGNED TO Monitor 1)
$LandscapeFolder = "C:\Users\iwill\wallpaper\wallpapers\landscape"

# Temporary folder to save the copied files (Will be created automatically if it doesn't exist)
$SlideshowTempFolder = "C:\Users\iwill\wallpaper\wallpapers"

# Final paths for the temporary files (Swapped assignment)
$NewWallpaperPathMonitor1 = Join-Path $SlideshowTempFolder "Monitor1_Landscape.jpg"  # Changed to Landscape
$NewWallpaperPathMonitor2 = Join-Path $SlideshowTempFolder "Monitor2_Portrait.jpg"   # Changed to Portrait


# =================================================================
# 2. Preparation (Folder Creation)
# =================================================================

# Create the temporary folder if it doesn't exist.
if (-not (Test-Path $SlideshowTempFolder)) {
    Write-Host "Creating temporary folder: $SlideshowTempFolder"
    New-Item -Path $SlideshowTempFolder -ItemType Directory | Out-Null
}


# =================================================================
# 3. File Selection and Copy for Monitor 1 (Landscape)
# =================================================================

Write-Host "--- Processing Monitor 1 (Index 0) - Assigned Landscape ---"

# Select files only (.jpg, .png, .bmp) from the Landscape folder and its subdirectories.
$LandscapeFiles = Get-ChildItem -Path $LandscapeFolder -File -Include "*.jpg", "*.png", "*.bmp" -Recurse | Select-Object -ExpandProperty FullName

if ($LandscapeFiles.Count -eq 0) {
    Write-Error "No usable image files found in the Landscape image folder ($LandscapeFolder). Skipping Monitor 1."
} else {
    # Select one image file randomly and copy it.
    $RandomLandscape = Get-Random -InputObject $LandscapeFiles
    Copy-Item -Path $RandomLandscape -Destination $NewWallpaperPathMonitor1 -Force
    Write-Host "Success: File '$($RandomLandscape)' copied to '$NewWallpaperPathMonitor1'."

    # Set Wallpaper for Monitor 1 (Index 0) - Uses -First 1
    Write-Host "Setting wallpaper for the first monitor (Index 0)..."
    Get-Monitor | Select-Object -First 1 | Set-Wallpaper -Path $NewWallpaperPathMonitor1
}


# =================================================================
# 4. File Selection and Copy for Monitor 2 (Portrait)
# =================================================================

Write-Host "`n--- Processing Monitor 2 (Index 1) - Assigned Portrait ---"

# Select files only (.jpg, .png, .bmp) from the Portrait folder and its subdirectories.
$PortraitFiles = Get-ChildItem -Path $PortraitFolder -File -Include "*.jpg", "*.png", "*.bmp" -Recurse | Select-Object -ExpandProperty FullName

if ($PortraitFiles.Count -eq 0) {
    Write-Error "No usable image files found in the Portrait image folder ($PortraitFolder). Skipping Monitor 2."
} else {
    # Select one image file randomly and copy it.
    $RandomPortrait = Get-Random -InputObject $PortraitFiles
    Copy-Item -Path $RandomPortrait -Destination $NewWallpaperPathMonitor2 -Force
    Write-Host "Success: File '$($RandomPortrait)' copied to '$NewWallpaperPathMonitor2'."

    # Set Wallpaper for Monitor 2 (Index 1) - ***수정된 부분: Index 1을 명시적으로 선택***
    Write-Host "Setting wallpaper for the second monitor (Index 1)..."
    Get-Monitor | Where-Object {$_.Index -eq 1} | Set-Wallpaper -Path $NewWallpaperPathMonitor2
}

Write-Host "`nTask Complete: Dual monitor wallpaper configuration attempt finished with swapped assignments."