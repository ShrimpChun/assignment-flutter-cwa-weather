import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('顯示對應的錯誤訊息', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeatherErrorView(failure: LocationNotFoundFailure('新竹市')),
        ),
      ),
    );

    expect(find.byKey(const Key('weatherErrorView')), findsOneWidget);
    expect(
      find.text(const LocationNotFoundFailure('新竹市').message),
      findsOneWidget,
    );
  });

  testWidgets('提供 onRetry 時顯示重試按鈕，點擊會觸發回呼', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherErrorView(
            failure: const NetworkFailure(),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('重試'), findsOneWidget);
    await tester.tap(find.text('重試'));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets('未提供 onRetry 時不顯示重試按鈕', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WeatherErrorView(failure: InvalidInputFailure())),
      ),
    );

    expect(find.text('重試'), findsNothing);
  });
}
