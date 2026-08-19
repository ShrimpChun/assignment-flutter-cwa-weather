import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('顯示載入指示器與說明文字', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WeatherLoadingView())),
    );

    expect(find.byKey(const Key('weatherLoadingView')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('正在查詢天氣資料…'), findsOneWidget);
  });
}
