import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_period_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('顯示天氣描述、溫度區間、降雨機率與體感舒適度', (tester) async {
    final period = WeatherPeriod(
      startTime: DateTime(2026, 8, 19, 18),
      endTime: DateTime(2026, 8, 20, 6),
      weatherDescription: '多雲時晴',
      rainProbabilityPercent: 20,
      minTemperatureCelsius: 26,
      maxTemperatureCelsius: 30,
      comfortIndex: '舒適',
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WeatherPeriodCard(period: period))),
    );

    expect(find.text('多雲時晴'), findsOneWidget);
    expect(find.text('26° - 30°'), findsOneWidget);
    expect(find.text('降雨機率 20%'), findsOneWidget);
    expect(find.text('體感 舒適'), findsOneWidget);
  });

  testWidgets('降雨機率為 null 時不顯示降雨機率標籤', (tester) async {
    final period = WeatherPeriod(
      startTime: DateTime(2026, 8, 19, 18),
      endTime: DateTime(2026, 8, 20, 6),
      weatherDescription: '晴',
      rainProbabilityPercent: null,
      minTemperatureCelsius: 26,
      maxTemperatureCelsius: 30,
      comfortIndex: '舒適',
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WeatherPeriodCard(period: period))),
    );

    expect(find.textContaining('降雨機率'), findsNothing);
  });
}
