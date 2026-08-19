import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_initial_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('顯示提示圖示與引導文字', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WeatherInitialView())),
    );

    expect(find.byKey(const Key('weatherInitialView')), findsOneWidget);
    expect(find.text('輸入地區名稱開始查詢'), findsOneWidget);
    expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
  });
}
