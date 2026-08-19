import 'package:flutter/material.dart';

/// 依天氣現象文字描述（如「多雲時晴」「短暫雷陣雨」）挑選合適的圖示。
///
/// 中央氣象署 API 並未直接提供簡化的天氣分類，僅提供人類可讀的
/// 文字描述，因此以關鍵字比對的方式挑選最貼切的圖示；比對順序由
/// 較劇烈的天氣現象排到較溫和的現象，確保「短暫雷陣雨」優先被判定
/// 為雷雨而非單純的雲。
IconData weatherIconFor(String description) {
  if (description.contains('雷')) return Icons.thunderstorm_rounded;
  if (description.contains('雨')) return Icons.umbrella_rounded;
  if (description.contains('雪')) return Icons.ac_unit_rounded;
  if (description.contains('霧') || description.contains('靄')) {
    return Icons.foggy;
  }
  if (description.contains('陰')) return Icons.cloud_rounded;
  if (description.contains('雲')) return Icons.wb_cloudy_rounded;
  if (description.contains('晴')) return Icons.wb_sunny_rounded;
  return Icons.cloud_outlined;
}
