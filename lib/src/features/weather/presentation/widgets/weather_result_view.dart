import 'package:flutter/material.dart';

import '../../data/models/location_forecast.dart';
import 'weather_period_card.dart';

/// 查詢成功後顯示天氣預報結果的畫面。
class WeatherResultView extends StatelessWidget {
  const WeatherResultView({
    required this.forecast,
    required this.onRefresh,
    super.key,
  });

  final LocationForecast forecast;

  /// 下拉刷新時觸發，重新查詢目前地區的天氣。
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const Key('weatherResultView'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  forecast.locationName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '今明 36 小時天氣預報',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (final period in forecast.periods) ...[
            WeatherPeriodCard(period: period),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
