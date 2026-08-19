import 'dart:async';

import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/data/repositories/weather_repository.dart';
import 'package:cwa_weather/src/features/weather/presentation/screens/weather_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository repository;

  final taipeiForecast = LocationForecast(
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
    ],
  );

  setUp(() {
    repository = _MockWeatherRepository();
  });

  Widget buildTestable() {
    return ProviderScope(
      overrides: [weatherRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: WeatherHomeScreen()),
    );
  }

  testWidgets('啟動時顯示初始畫面', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.byKey(const Key('weatherInitialView')), findsOneWidget);
  });

  testWidgets('輸入地區名稱並點擊確認後，依序顯示 loading 再顯示查詢結果', (
    tester,
  ) async {
    final completer = Completer<LocationForecast>();
    when(
      () => repository.fetchForecast('臺北市'),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestable());
    await tester.enterText(
      find.byKey(const Key('weatherSearchField')),
      '臺北市',
    );
    await tester.tap(find.byKey(const Key('weatherSearchConfirmButton')));
    await tester.pump();

    expect(find.byKey(const Key('weatherLoadingView')), findsOneWidget);

    completer.complete(taipeiForecast);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weatherResultView')), findsOneWidget);
  });

  testWidgets('未輸入任何文字即點擊確認時，顯示輸入驗證錯誤且不呼叫 API', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());
    await tester.tap(find.byKey(const Key('weatherSearchConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weatherErrorView')), findsOneWidget);
    expect(find.text(const InvalidInputFailure().message), findsOneWidget);
    verifyNever(() => repository.fetchForecast(any()));
  });

  testWidgets('查詢地區不存在時，顯示對應的錯誤說明', (tester) async {
    when(
      () => repository.fetchForecast('不存在的地區'),
    ).thenThrow(const LocationNotFoundFailure('不存在的地區'));

    await tester.pumpWidget(buildTestable());
    await tester.enterText(
      find.byKey(const Key('weatherSearchField')),
      '不存在的地區',
    );
    await tester.tap(find.byKey(const Key('weatherSearchConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weatherErrorView')), findsOneWidget);
    expect(
      find.text(const LocationNotFoundFailure('不存在的地區').message),
      findsOneWidget,
    );
  });

  testWidgets('點擊快捷縣市選單會自動帶入名稱並查詢', (tester) async {
    final forecast = LocationForecast(
      locationName: '高雄市',
      periods: taipeiForecast.periods,
    );
    when(
      () => repository.fetchForecast('高雄市'),
    ).thenAnswer((_) async => forecast);

    await tester.pumpWidget(buildTestable());
    await tester.tap(find.text('高雄市'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weatherResultView')), findsOneWidget);
    verify(() => repository.fetchForecast('高雄市')).called(1);
  });

  testWidgets('於鍵盤輸入完成動作時也會觸發查詢', (tester) async {
    final forecast = LocationForecast(
      locationName: '臺中市',
      periods: taipeiForecast.periods,
    );
    when(
      () => repository.fetchForecast('臺中市'),
    ).thenAnswer((_) async => forecast);

    await tester.pumpWidget(buildTestable());
    await tester.enterText(
      find.byKey(const Key('weatherSearchField')),
      '臺中市',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weatherResultView')), findsOneWidget);
  });

  testWidgets('查詢中停用輸入框與確認按鈕，避免重複送出', (tester) async {
    final completer = Completer<LocationForecast>();
    when(
      () => repository.fetchForecast('臺北市'),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestable());
    await tester.enterText(
      find.byKey(const Key('weatherSearchField')),
      '臺北市',
    );
    await tester.tap(find.byKey(const Key('weatherSearchConfirmButton')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('weatherSearchConfirmButton')),
    );
    expect(button.onPressed, isNull);

    final textField = tester.widget<TextField>(
      find.byKey(const Key('weatherSearchField')),
    );
    expect(textField.enabled, isFalse);

    completer.complete(taipeiForecast);
    await tester.pumpAndSettle();
  });
}
