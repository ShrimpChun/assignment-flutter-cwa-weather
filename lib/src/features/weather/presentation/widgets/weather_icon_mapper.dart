import 'package:flutter/material.dart';

/// 依天氣現象文字描述（如「多雲時晴」「短暫雷陣雨」）挑選合適的圖示。
///
/// 中央氣象署 API 的 `Wx` 要素同時提供文字描述（`parameterName`）與
/// 數值代碼（`parameterValue`），本專案的資料模型目前只保留前者；
/// 因此這裡以關鍵字比對文字描述來挑選最貼切的圖示，而非對照官方的
/// 天氣代碼表。比對順序由較劇烈、較具參考價值的現象排到較溫和的
/// 現象：先看「雷／雨／雪／霧」等具體降水或能見度現象，其次才看
/// 「晴／陰／雲」這類單純描述雲量的字眼；「晴」被排在「陰」「雲」
/// 之前，確保「多雲時晴」「晴時多雲」這類描述會顯示晴天圖示，
/// 而不是被字串中同時出現的「雲」或「陰」字搶先比對到。
IconData weatherIconFor(String description) {
  if (description.contains('雷')) return Icons.thunderstorm_rounded;
  if (description.contains('雨')) return Icons.umbrella_rounded;
  if (description.contains('雪')) return Icons.ac_unit_rounded;
  if (description.contains('霧') || description.contains('靄')) {
    return Icons.foggy;
  }
  if (description.contains('晴')) return Icons.wb_sunny_rounded;
  if (description.contains('陰')) return Icons.cloud_rounded;
  if (description.contains('雲')) return Icons.wb_cloudy_rounded;
  return Icons.cloud_outlined;
}
