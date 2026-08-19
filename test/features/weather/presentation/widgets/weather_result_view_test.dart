import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_period_card.dart';
import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final forecast = LocationForecast(
    locationName: '臺北市',
    periods: [
      WeatherPeriod(
        startTime: DateTime(2026, 8, 19, 18),
        endTime: DateTime(2026, 8, 20, 6),
        weatherDescription: '多雲',
        rainProbabilityPercent: 20,
        minTemperatureCelsius: 26,
        maxTemperatureCelsius: 30,
        comfortIndex: '舒適',
      ),
      WeatherPeriod(
        startTime: DateTime(2026, 8, 20, 6),
        endTime: DateTime(2026, 8, 20, 18),
        weatherDescription: '晴時多雲',
        rainProbabilityPercent: 10,
        minTemperatureCelsius: 25,
        maxTemperatureCelsius: 32,
        comfortIndex: '悶熱',
      ),
    ],
  );

  testWidgets('顯示地區名稱與各時段天氣卡片', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherResultView(forecast: forecast, onRefresh: () async {}),
        ),
      ),
    );

    expect(find.byKey(const Key('weatherResultView')), findsOneWidget);
    expect(find.text('臺北市'), findsOneWidget);
    expect(find.byType(WeatherPeriodCard), findsNWidgets(2));
  });

  testWidgets('下拉刷新時會觸發 onRefresh 回呼', (tester) async {
    var refreshed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherResultView(
            forecast: forecast,
            onRefresh: () async => refreshed = true,
          ),
        ),
      ),
    );

    await tester.fling(
      find.byKey(const Key('weatherResultView')),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(refreshed, isTrue);
  });
}
