import 'package:cwa_weather/src/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatWeatherDateTime 格式化為 M/d (週) HH:mm', () {
    final time = DateTime(2026, 8, 19, 18, 5);
    expect(formatWeatherDateTime(time), '8/19 (三) 18:05');
  });

  test('formatWeatherDateTime 會補零至兩位數', () {
    final time = DateTime(2026, 1, 1, 6, 3);
    expect(formatWeatherDateTime(time), '1/1 (四) 06:03');
  });

  test('formatWeatherTimeRange 以 ~ 連接起訖時間', () {
    final start = DateTime(2026, 8, 19, 18);
    final end = DateTime(2026, 8, 20, 6);
    expect(
      formatWeatherTimeRange(start, end),
      '8/19 (三) 18:00 ~ 8/20 (四) 06:00',
    );
  });
}
