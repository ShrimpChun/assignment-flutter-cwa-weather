import 'dart:async';

import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/data/repositories/weather_repository.dart';
import 'package:cwa_weather/src/features/weather/presentation/providers/weather_notifier.dart';
import 'package:cwa_weather/src/features/weather/presentation/state/weather_ui_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository repository;
  late ProviderContainer container;

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
    ],
  );

  void stubFetch(
    String locationName,
    Future<LocationForecast> Function(Invocation) answer,
  ) {
    when(
      () => repository.fetchForecast(
        locationName,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(answer);
  }

  setUp(() {
    repository = _MockWeatherRepository();
    container = ProviderContainer(
      overrides: [weatherRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('初始狀態為 WeatherInitial', () {
    expect(container.read(weatherNotifierProvider), const WeatherInitial());
  });

  test('輸入為空白時，直接進入 WeatherError(InvalidInputFailure)，不呼叫 API', () async {
    await container.read(weatherNotifierProvider.notifier).search('   ');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(InvalidInputFailure()),
    );
    verifyNever(
      () => repository.fetchForecast(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('查詢成功時，先切換為 loading 再切換為 success', () async {
    stubFetch('臺北市', (_) async {
      expect(container.read(weatherNotifierProvider), const WeatherLoading());
      return forecast;
    });

    await container.read(weatherNotifierProvider.notifier).search('臺北市');

    expect(container.read(weatherNotifierProvider), WeatherSuccess(forecast));
  });

  test('查詢時會自動去除輸入前後空白', () async {
    stubFetch('臺北市', (_) async => forecast);

    await container.read(weatherNotifierProvider.notifier).search('  臺北市  ');

    verify(
      () => repository.fetchForecast(
        '臺北市',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  test('查詢失敗時切換為 WeatherError 並帶入對應的 Failure', () async {
    stubFetch(
      '新竹市',
      (_) => Future.error(const LocationNotFoundFailure('新竹市')),
    );

    await container.read(weatherNotifierProvider.notifier).search('新竹市');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(LocationNotFoundFailure('新竹市')),
    );
  });

  test('資料來源拋出非 WeatherFailure 的例外時，轉換為 UnknownFailure', () async {
    stubFetch('臺北市', (_) => Future.error(Exception('boom')));

    await container.read(weatherNotifierProvider.notifier).search('臺北市');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(UnknownFailure()),
    );
  });

  test('較舊查詢的回應較晚抵達時，不會覆蓋較新查詢的結果', () async {
    final taipeiCompleter = Completer<LocationForecast>();
    final kaohsiungForecast = LocationForecast(
      locationName: '高雄市',
      periods: forecast.periods,
    );

    stubFetch('臺北市', (_) => taipeiCompleter.future);
    stubFetch('高雄市', (_) async => kaohsiungForecast);

    final notifier = container.read(weatherNotifierProvider.notifier);
    final firstSearch = notifier.search('臺北市');
    final secondSearch = notifier.search('高雄市');
    await secondSearch;

    expect(
      container.read(weatherNotifierProvider),
      WeatherSuccess(kaohsiungForecast),
    );

    taipeiCompleter.complete(forecast);
    await firstSearch;

    expect(
      container.read(weatherNotifierProvider),
      WeatherSuccess(kaohsiungForecast),
    );
  });

  test('送出新查詢時，會主動取消前一個尚未完成的請求', () async {
    final completer = Completer<LocationForecast>();
    stubFetch('臺北市', (_) => completer.future);
    stubFetch('高雄市', (_) async => forecast);

    final notifier = container.read(weatherNotifierProvider.notifier);
    final firstSearch = notifier.search('臺北市');

    final firstCall = verify(
      () => repository.fetchForecast(
        '臺北市',
        cancelToken: captureAny(named: 'cancelToken'),
      ),
    ).captured;
    final firstToken = firstCall.single as CancelToken;
    expect(firstToken.isCancelled, isFalse);

    await notifier.search('高雄市');

    expect(firstToken.isCancelled, isTrue);

    completer.complete(forecast);
    await firstSearch;
  });

  test('refresh() 不會切換為 WeatherLoading，重新整理期間仍保留原有結果', () async {
    final notifier = container.read(weatherNotifierProvider.notifier);
    stubFetch('臺北市', (_) async => forecast);
    await notifier.search('臺北市');
    expect(container.read(weatherNotifierProvider), WeatherSuccess(forecast));

    final refreshedForecast = LocationForecast(
      locationName: '臺北市',
      periods: forecast.periods,
    );
    final completer = Completer<LocationForecast>();
    stubFetch('臺北市', (_) => completer.future);

    final refresh = notifier.refresh('臺北市');
    expect(container.read(weatherNotifierProvider), WeatherSuccess(forecast));

    completer.complete(refreshedForecast);
    await refresh;

    expect(
      container.read(weatherNotifierProvider),
      WeatherSuccess(refreshedForecast),
    );
  });

  test('refresh() 失敗時切換為 WeatherError', () async {
    final notifier = container.read(weatherNotifierProvider.notifier);
    stubFetch('臺北市', (_) async => forecast);
    await notifier.search('臺北市');

    stubFetch(
      '臺北市',
      (_) => Future.error(const ServerFailure(statusCode: 500)),
    );
    await notifier.refresh('臺北市');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(ServerFailure(statusCode: 500)),
    );
  });

  test('reset() 會取消尚未完成的查詢請求，不會在重設後覆蓋畫面', () async {
    final completer = Completer<LocationForecast>();
    stubFetch('臺北市', (_) => completer.future);

    final notifier = container.read(weatherNotifierProvider.notifier);
    final search = notifier.search('臺北市');
    notifier.reset();
    completer.complete(forecast);
    await search;

    expect(container.read(weatherNotifierProvider), const WeatherInitial());
  });

  test('reset() 會將狀態還原為 WeatherInitial', () async {
    stubFetch('臺北市', (_) async => forecast);
    final notifier = container.read(weatherNotifierProvider.notifier);
    await notifier.search('臺北市');

    notifier.reset();

    expect(container.read(weatherNotifierProvider), const WeatherInitial());
  });
}
