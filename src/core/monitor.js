// 원래는 도커환경에서 JS 사용해서 모니터 정보를 불러오려 했으나
// 도커 내부에서 모니터 정보에 접근할 수 없고, 로컬에 JS를 깔기 싫었기 때문에,,, 쓰지 않는 코드.

// import si from 'systeminformation';
//
// /**
//  * 모든 모니터 정보 가져오기
//  * @returns {Promise<Array>} 모니터 배열
//  */
// export async function getMonitors() {
//   try {
//     const graphics = await si.graphics();
//     const displays = graphics.displays;
//
//     return displays.map((d, idx) => ({
//       id: idx,
//       model: d.model,
//       width: d.currentResolution.width,
//       height: d.currentResolution.height,
//       orientation: d.currentResolution.height > d.currentResolution.width ? 'portrait' : 'landscape',
//       isPrimary: d.primary,
//     }));
//   } catch (err) {
//     console.error('모니터 정보 가져오기 실패:', err);
//     return [];
//   }
// }
//
// /**
//  * 모니터 정보 출력 (디버깅용)
//  */
// export async function printMonitorInfo() {
//   const monitors = await getMonitors();
//
//   monitors.forEach(m => {
//     console.log(`Monitor ${m.id} (${m.isPrimary ? 'Primary' : 'Secondary'})`);
//     console.log(`  Model: ${m.model}`);
//     console.log(`  Resolution: ${m.width}x${m.height}`);
//     console.log(`  Orientation: ${m.orientation}`);
//     console.log('---------------------------');
//   });
// }0
