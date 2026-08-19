import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../data/models/weather_period.dart';
import 'weather_icon_mapper.dart';

/// 顯示單一時段（通常 12 小時）天氣預報的卡片。
class WeatherPeriodCard extends StatelessWidget {
  const WeatherPeriodCard({required this.period, super.key});

  final WeatherPeriod period;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatWeatherTimeRange(period.startTime, period.endTime),
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  weatherIconFor(period.weatherDescription),
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    period.weatherDescription,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${period.minTemperatureCelsius}° - ${period.maxTemperatureCelsius}°',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (period.rainProbabilityPercent != null)
                  _InfoChip(
                    icon: Icons.water_drop_outlined,
                    label: '降雨機率 ${period.rainProbabilityPercent}%',
                  ),
                _InfoChip(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  label: '體感 ${period.comfortIndex}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.primary),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
