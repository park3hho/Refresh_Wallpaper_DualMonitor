import os
import random
import ctypes
import winreg
from pathlib import Path
from PIL import Image

# 모니터별 EDID 값
MONITOR_EDID = [
    "00ffffffffffff0030aec6680000000021230103803c22782e9985ad5145a3240e5054bdef00818081009500a9c0b300d1c0d1fc01016a5e00a0a0a029503020350055502100001a000000fd0830901eff3c000a202020202020000000fc004c6567696f6e203237512d3130000000ff0055504156373132300a202020200155",
    "00ffffffffffff0030aec6680000000020230104b53c22783b9985ad5145a3240e5054bdef00818081009500a9c0b300d1c0d1fc01016a5e00a0a0a029503020350055502100001a000000fd0830f0f2f262010a202020202020000000fc004c6567696f6e203237512d3130000000ff0055504156333239330a2020202002bd"
]

# EDID → 카테고리 매핑
MONITOR_CATEGORY_MAP = {
    "00ffffffffffff0030aec668000000002123": "landscape",
    "00ffffffffffff0030aec668000000002023": "portrait"
}

BASE_DIR = Path("wallpapers")

def edid_to_category(edid):
    for prefix, cat in MONITOR_CATEGORY_MAP.items():
        if edid.startswith(prefix):
            return cat
    return "landscape"

def get_random_wallpapers():
    results = []
    for edid in MONITOR_EDID:
        category = edid_to_category(edid)
        folder_path = BASE_DIR / category
        if not folder_path.exists():
            results.append(None)
            continue
        files = [f for f in folder_path.iterdir() if f.suffix.lower() in [".jpg", ".jpeg", ".png"]]
        if not files:
            results.append(None)
            continue
        selected_file = random.choice(files)
        results.append(selected_file.resolve())
    return results

def convert_to_bmp(image_path):
    bmp_path = image_path.with_suffix(".bmp")
    img = Image.open(image_path)
    img.save(bmp_path, "BMP")
    return bmp_path

# 레지스트리에서 모니터별 배경 경로 적용
def set_wallpapers_multimonitor(bmp_paths):
    # Windows 레지스트리 경로
    key_path = r"Control Panel\Desktop"
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_SET_VALUE) as key:
            # 첫 번째 모니터는 wallpaper 바로 적용
            winreg.SetValueEx(key, "Wallpaper", 0, winreg.REG_SZ, str(bmp_paths[0]))

            # 여러 모니터용 설정
            # Fill registry values for each monitor
            for i, bmp in enumerate(bmp_paths):
                # 개인적으로 이름 규칙 적용
                value_name = f"TranscodedImageCache{i}"
                try:
                    winreg.SetValueEx(key, value_name, 0, winreg.REG_BINARY, open(bmp, "rb").read())
                except Exception as e:
                    print(f"모니터 {i} TranscodedImageCache 설정 실패: {e}")

        # 변경 적용
        SPI_SETDESKWALLPAPER = 20
        SPIF_UPDATEINIFILE = 1
        SPIF_SENDCHANGE = 2
        ctypes.windll.user32.SystemParametersInfoW(
            SPI_SETDESKWALLPAPER, 0, str(bmp_paths[0]), SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
        )
    except Exception as e:
        print(f"멀티모니터 배경 적용 실패: {e}")

def apply_wallpapers():
    wallpapers = get_random_wallpapers()
    bmp_paths = []
    for i, wp in enumerate(wallpapers):
        if wp is None:
            print(f"모니터 {i} -> 이미지 없음")
            continue
        bmp_path = convert_to_bmp(wp)
        bmp_paths.append(bmp_path)
        print(f"모니터 {i} -> {bmp_path}")
    if bmp_paths:
        set_wallpapers_multimonitor(bmp_paths)

if __name__ == "__main__":
    apply_wallpapers()
