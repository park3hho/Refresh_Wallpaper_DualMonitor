#
# 스크립트 목적:
# 듀얼 모니터 환경에서, 가로/세로 전용 폴더에서 이미지를 무작위로 선택하여
# Windows 슬라이드 쇼 폴더(SlideshowTempFolder)에 복사함으로써 부팅 시마다
# 모니터별로 랜덤한 배경화면을 설정합니다.
#

# =========================================================================
# 1. 사용자 정의 설정 (필수 수정)
# =========================================================================

# 가로 배경화면이 저장된 실제 라이브러리 경로
$LandscapeFolder = "C:\Users\iwill\wallpaper\wallpapers\landscape"
# 세로 배경화면이 저장된 실제 라이브러리 경로
$PortraitFolder  = "C:\Users\iwill\wallpaper\wallpapers\portrait"

# Windows의 '슬라이드 쇼' 설정에서 지정할 최종 목적지 폴더입니다.
# ⚠️ 주의: 이 폴더의 기존 파일은 스크립트 실행 시 삭제됩니다.
$SlideshowTempFolder = "C:\Users\iwill\wallpaper\wallpapers"

# =========================================================================
# 2. 메인 로직: 랜덤 선택 및 복사
# =========================================================================

Write-Host "--- Start Random Rotation ---"

# 1. 목적지 폴더 정리
if (-not (Test-Path $SlideshowTempFolder)) {
    # 폴더가 없으면 생성
    New-Item -Path $SlideshowTempFolder -ItemType Directory | Out-Null
    Write-Host "TempFolderGeneration: $SlideshowTempFolder"
} else {
    # 기존 파일 모두 삭제 (새로운 두 개의 이미지만 남기기 위함)
    Write-Host "Clean Up latest WALLPAPER"
    Get-ChildItem -Path $SlideshowTempFolder -File | Where-Object { $_.Name -ne 'desktop.ini' } | Remove-Item -Force -ErrorAction SilentlyContinue
}

# 2. 가로(Landscape) 배경화면 무작위 선택 및 복사
$LandscapeFiles = Get-ChildItem -Path $LandscapeFolder\* -Include "*.jpg", "*.png", "*.bmp" | Select-Object -ExpandProperty FullName
if ($LandscapeFiles.Count -gt 0) {
    $RandomLandscape = Get-Random -InputObject $LandscapeFiles
    # 임시 폴더에 고정된 이름으로 복사
    Copy-Item -Path $RandomLandscape -Destination (Join-Path $SlideshowTempFolder "Wallpaper_Landscape.jpg") -Force
    Write-Host "Success: Selected Landscape: $RandomLandscape"
} else {
    Write-Host "Failure: Landscape Folder No  Image: ($LandscapeFolder)."
}

# 3. 세로(Portrait) 배경화면 무작위 선택 및 복사
$PortraitFiles = Get-ChildItem -Path $PortraitFolder\* -Include "*.jpg", "*.png", "*.bmp" | Select-Object -ExpandProperty FullName
if ($PortraitFiles.Count -gt 0) {
    $RandomPortrait = Get-Random -InputObject $PortraitFiles
    # 임시 폴더에 고정된 이름으로 복사
    Copy-Item -Path $RandomPortrait -Destination (Join-Path $SlideshowTempFolder "Wallpaper_Portrait.jpg") -Force
    Write-Host "Success: $RandomPortrait"
} else {
    Write-Host "Failure: Portrait Folder No Image ($PortraitFolder)"
}

# 4. Windows 배경화면 새로고침 유도 (API 호출)
# Windows의 배경화면 변경 API를 호출하여 슬라이드 쇼를 강제로 새로고침하도록 유도합니다.

# 필요한 Win32 API 함수 정의
$code = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
public const int SPI_SETDESKWALLPAPER = 0x0014;
public const uint SPIF_UPDATEINIFILE = 0x01;
"@
Add-Type -MemberDefinition $code -Namespace Win32 -Name Desktop

# 임시 폴더 내의 파일 중 하나를 임시로 설정하여 Windows가 변경을 감지하도록 유도합니다.
[Win32.Desktop]::SystemParametersInfo([Win32.Desktop]::SPI_SETDESKWALLPAPER, 0, (Join-Path $SlideshowTempFolder "Wallpaper_Landscape.jpg"), [Win32.Desktop]::SPIF_UPDATEINIFILE) | Out-Null

Write-Host "--- Change Success ---"