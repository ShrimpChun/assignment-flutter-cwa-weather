import 'package:flutter/material.dart';

import 'weather_status_message.dart';

/// 呼叫天氣 API 期間顯示的載入畫面。
class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      label: '正在查詢天氣資料，請稍候',
      child: WeatherStatusMessage(
        key: const Key('weatherLoadingView'),
        visual: CircularProgressIndicator(color: colorScheme.primary),
        title: '正在查詢天氣資料…',
        titleStyle: textTheme.bodyLarge,
      ),
    );
  }
}
