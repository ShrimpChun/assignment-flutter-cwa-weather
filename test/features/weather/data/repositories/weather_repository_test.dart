import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:cwa_weather/src/features/weather/data/repositories/weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

void main() {
  late _MockWeatherRemoteDataSource dataSource;
  late WeatherRepositoryImpl repository;

  setUp(() {
    dataSource = _MockWeatherRemoteDataSource();
    repository = WeatherRepositoryImpl(dataSource);
  });

  test('fetchForecast 會將呼叫委派給 WeatherRemoteDataSource 並回傳其結果', () async {
    const forecast = LocationForecast(locationName: '臺北市', periods: []);
    when(
      () => dataSource.fetchForecast('臺北市'),
    ).thenAnswer((_) async => forecast);

    final result = await repository.fetchForecast('臺北市');

    expect(result, forecast);
    verify(() => dataSource.fetchForecast('臺北市')).called(1);
  });

  test('資料來源拋出的 WeatherFailure 會原樣往上傳遞', () async {
    when(
      () => dataSource.fetchForecast('不存在的地區'),
    ).thenThrow(const LocationNotFoundFailure('不存在的地區'));

    await expectLater(
      repository.fetchForecast('不存在的地區'),
      throwsA(isA<LocationNotFoundFailure>()),
    );
  });
}
