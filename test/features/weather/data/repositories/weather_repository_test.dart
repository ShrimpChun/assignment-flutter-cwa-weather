import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/models/weather_period.dart';
import 'package:cwa_weather/src/features/weather/data/repositories/weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

void main() {
  late _MockWeatherRemoteDataSource dataSource;
  late WeatherRepositoryImpl repository;

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
    dataSource = _MockWeatherRemoteDataSource();
    repository = WeatherRepositoryImpl(dataSource);
  });

  test('fetchForecast 會將呼叫委派給 WeatherRemoteDataSource 並回傳其結果', () async {
    when(
      () => dataSource.fetchForecast(
        '臺北市',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => forecast);

    final result = await repository.fetchForecast('臺北市');

    expect(result, forecast);
    verify(
      () => dataSource.fetchForecast(
        '臺北市',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  test('資料來源拋出的 WeatherFailure 會原樣往上傳遞', () async {
    when(
      () => dataSource.fetchForecast(
        '不存在的地區',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenThrow(const LocationNotFoundFailure('不存在的地區'));

    await expectLater(
      repository.fetchForecast('不存在的地區'),
      throwsA(isA<LocationNotFoundFailure>()),
    );
  });
}
