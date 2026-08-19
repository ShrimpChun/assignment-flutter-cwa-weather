import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/data/repositories/weather_repository.dart';
import 'package:cwa_weather/src/features/weather/presentation/providers/weather_notifier.dart';
import 'package:cwa_weather/src/features/weather/presentation/state/weather_ui_state.dart';
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
    verifyNever(() => repository.fetchForecast(any()));
  });

  test('查詢成功時，先切換為 loading 再切換為 success', () async {
    when(() => repository.fetchForecast('臺北市')).thenAnswer((_) async {
      expect(container.read(weatherNotifierProvider), const WeatherLoading());
      return forecast;
    });

    await container.read(weatherNotifierProvider.notifier).search('臺北市');

    expect(container.read(weatherNotifierProvider), WeatherSuccess(forecast));
  });

  test('查詢時會自動去除輸入前後空白', () async {
    when(
      () => repository.fetchForecast('臺北市'),
    ).thenAnswer((_) async => forecast);

    await container.read(weatherNotifierProvider.notifier).search('  臺北市  ');

    verify(() => repository.fetchForecast('臺北市')).called(1);
  });

  test('查詢失敗時切換為 WeatherError 並帶入對應的 Failure', () async {
    when(
      () => repository.fetchForecast('新竹市'),
    ).thenThrow(const LocationNotFoundFailure('新竹市'));

    await container.read(weatherNotifierProvider.notifier).search('新竹市');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(LocationNotFoundFailure('新竹市')),
    );
  });

  test('資料來源拋出非 WeatherFailure 的例外時，轉換為 UnknownFailure', () async {
    when(() => repository.fetchForecast('臺北市')).thenThrow(Exception('boom'));

    await container.read(weatherNotifierProvider.notifier).search('臺北市');

    expect(
      container.read(weatherNotifierProvider),
      const WeatherError(UnknownFailure()),
    );
  });

  test('reset() 會將狀態還原為 WeatherInitial', () async {
    when(
      () => repository.fetchForecast('臺北市'),
    ).thenAnswer((_) async => forecast);
    final notifier = container.read(weatherNotifierProvider.notifier);
    await notifier.search('臺北市');

    notifier.reset();

    expect(container.read(weatherNotifierProvider), const WeatherInitial());
  });
}
