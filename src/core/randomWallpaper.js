import fs from 'fs';
import path from 'path';
import { execFile } from 'child_process';

// 이미 확인한 EDID 값
const MONITOR_EDID = [
  "00ffffffffffff0030aec6680000000021230103803c22782e9985ad5145a3240e5054bdef00818081009500a9c0b300d1c0d1fc01016a5e00a0a0a029503020350055502100001a000000fd0830901eff3c000a202020202020000000fc004c6567696f6e203237512d3130000000ff0055504156373132300a202020200155",
  "00ffffffffffff0030aec6680000000020230104b53c22783b9985ad5145a3240e5054bdef00818081009500a9c0b300d1c0d1fc01016a5e00a0a0a029503020350055502100001a000000fd0830f0f2f262010a202020202020000000fc004c6567696f6e203237512d3130000000ff0055504156333239330a2020202002bd"
];

// EDID 기준 카테고리 매핑
const MONITOR_CATEGORY_MAP = {
  "00ffffffffffff0030aec668000000002123": "landscape",
  "00ffffffffffff0030aec668000000002023": "portrait"
};

export function getRandomWallpaper() {
  const baseDir = path.resolve('wallpapers');
  const results = [];

  MONITOR_EDID.forEach((edid, index) => {
    let selectedCategory = "landscape"; // 기본값
    for (const [prefix, category] of Object.entries(MONITOR_CATEGORY_MAP)) {
      if (edid.startsWith(prefix)) {
        selectedCategory = category;
        break;
      }
    }

    const folderPath = path.join(baseDir, selectedCategory);

    if (!fs.existsSync(folderPath)) {
      console.error(`폴더 없음: ${folderPath}`);
      results.push(null);
      return;
    }

    const files = fs.readdirSync(folderPath).filter(file =>
      file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png')
    );

    if (files.length === 0) {
      console.error(`이미지 파일 없음: ${folderPath}`);
      results.push(null);
      return;
    }

    const randomFile = files[Math.floor(Math.random() * files.length)];
    const fullPath = path.join(folderPath, randomFile);

    results.push({
      monitorIndex: index,
      category: selectedCategory,
      file: randomFile,
      fullPath
    });
  });

  // ---- 여기서 exe 호출 ----
  results.forEach(item => {
    if (!item) return;
    execFile('wallpaper-setter.exe', [item.fullPath, item.monitorIndex.toString()], (err, stdout, stderr) => {
      if (err) {
        console.error(`모니터 ${item.monitorIndex} 바탕화면 변경 실패`, err);
        return;
      }
      console.log(`모니터 ${item.monitorIndex} 바탕화면 변경 완료: ${item.fullPath}`);
      if (stdout) console.log(stdout);
      if (stderr) console.error(stderr);
    });
  });

  return results;
}
