import 'package:flutter/material.dart';

/// 呼叫天氣 API 期間顯示的載入畫面。
class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Semantics(
        liveRegion: true,
        label: '正在查詢天氣資料，請稍候',
        child: Column(
          key: const Key('weatherLoadingView'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              '正在查詢天氣資料…',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
