import 'package:flutter/material.dart';

import 'weather_status_message.dart';

/// 尚未輸入查詢條件時顯示的初始畫面。
class WeatherInitialView extends StatelessWidget {
  const WeatherInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WeatherStatusMessage(
      key: const Key('weatherInitialView'),
      visual: Icon(
        Icons.travel_explore_rounded,
        size: 96,
        color: colorScheme.primary.withValues(alpha: 0.6),
      ),
      title: '輸入地區名稱開始查詢',
      subtitle: '於上方搜尋欄輸入縣市名稱（例如：臺北市），\n即可查看今明 36 小時天氣預報。',
    );
  }
}
