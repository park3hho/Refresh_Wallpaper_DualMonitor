// Take Monitor Info

// import { printMonitorInfo } from './core/monitor.js';
//
// async function checkMonitor() {
//   console.log('=== 모니터 정보 확인 ===');
//   await printMonitorInfo();
// }
// checkMonitor();

// Refresh Wall Paper

import { getRandomWallpaper } from './core/randomWallpaper.js';

console.log("=== 랜덤 배경화면 선택 ===");

const wallpaper = getRandomWallpaper();

if (wallpaper) {
    console.log("선택된 카테고리:", wallpaper.category);
    console.log("선택된 파일명:", wallpaper.file);
    console.log("전체 경로:", wallpaper.fullPath);
} else {
    console.log("배경화면 선택 실패");
}
