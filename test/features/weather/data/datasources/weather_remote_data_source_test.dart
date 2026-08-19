import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/core/network/api_endpoints.dart';
import 'package:cwa_weather/src/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/weather_fixtures.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
  });

  Response<dynamic> responseWith(dynamic data, {int statusCode = 200}) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: ApiEndpoints.generalForecast36h),
      data: data,
      statusCode: statusCode,
    );
  }

  void stubGet(Response<dynamic> response) {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => response);
  }

  group('WeatherRemoteDataSource', () {
    test('未提供 API Key 時，直接拋出 MissingApiKeyFailure 且不呼叫 API', () async {
      final dataSource = WeatherRemoteDataSource(dio, apiKey: '');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<MissingApiKeyFailure>()),
      );
      verifyNever(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    });

    test('API Key 僅有空白字元時，視同未提供', () async {
      final dataSource = WeatherRemoteDataSource(dio, apiKey: '   ');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<MissingApiKeyFailure>()),
      );
    });

    test('查詢成功時回傳 LocationForecast，並帶入正確的查詢參數', () async {
      stubGet(responseWith(validForecastResponse()));
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      final forecast = await dataSource.fetchForecast('臺北市');

      expect(forecast.locationName, '臺北市');

      final captured = verify(
        () => dio.get<dynamic>(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect(captured[0], ApiEndpoints.generalForecast36h);
      final queryParameters = captured[1] as Map<String, dynamic>;
      expect(queryParameters['Authorization'], 'fake-key');
      expect(queryParameters['locationName'], '臺北市');
    });

    test('地區查無資料（location 為空陣列）時拋出 LocationNotFoundFailure', () async {
      stubGet(responseWith(emptyLocationResponse()));
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('不存在的地區'),
        throwsA(isA<LocationNotFoundFailure>()),
      );
    });

    test('API 回傳 success=false 時拋出 UnauthorizedFailure', () async {
      stubGet(responseWith(unauthorizedResponse()));
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'bad-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('回應主體不是 JSON 物件時拋出 DataParsingFailure', () async {
      stubGet(responseWith('<html>unexpected</html>'));
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('records 欄位缺漏時拋出 DataParsingFailure', () async {
      stubGet(responseWith({'success': 'true'}));
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('records.location 型別錯誤時拋出 DataParsingFailure', () async {
      stubGet(
        responseWith({
          'success': 'true',
          'records': {'location': 'not-a-list'},
        }),
      );
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('連線逾時時拋出 NetworkFailure', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: ApiEndpoints.generalForecast36h,
          ),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('裝置離線（connectionError）時拋出 NetworkFailure', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: ApiEndpoints.generalForecast36h,
          ),
          type: DioExceptionType.connectionError,
        ),
      );
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('HTTP 401 時拋出 UnauthorizedFailure（API Key 錯誤）', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: ApiEndpoints.generalForecast36h,
          ),
          type: DioExceptionType.badResponse,
          response: responseWith(null, statusCode: 401),
        ),
      );
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'wrong-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('HTTP 500 時拋出 ServerFailure', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: ApiEndpoints.generalForecast36h,
          ),
          type: DioExceptionType.badResponse,
          response: responseWith(null, statusCode: 500),
        ),
      );
      final dataSource = WeatherRemoteDataSource(dio, apiKey: 'fake-key');

      await expectLater(
        dataSource.fetchForecast('臺北市'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
