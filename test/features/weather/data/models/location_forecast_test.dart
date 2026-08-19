import 'package:cwa_weather/src/core/error/weather_failure.dart';
import 'package:cwa_weather/src/features/weather/data/models/location_forecast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/weather_fixtures.dart';

Map<String, dynamic> _validLocationJson() {
  final response = validForecastResponse();
  final records = response['records'] as Map<String, dynamic>;
  final locations = records['location'] as List<dynamic>;
  return Map<String, dynamic>.from(locations.first as Map<String, dynamic>);
}

void main() {
  group('LocationForecast.fromJson', () {
    test('解析合法資料時，正確取得地區名稱與各時段資訊', () {
      final forecast = LocationForecast.fromJson(_validLocationJson());

      expect(forecast.locationName, '臺北市');
      expect(forecast.periods, hasLength(2));

      final first = forecast.periods.first;
      expect(first.weatherDescription, '多雲');
      expect(first.minTemperatureCelsius, 26);
      expect(first.maxTemperatureCelsius, 30);
      expect(first.rainProbabilityPercent, 20);
      expect(first.comfortIndex, '舒適');
      expect(first.startTime, DateTime.parse('2026-08-19 18:00:00'));
      expect(first.endTime, DateTime.parse('2026-08-20 06:00:00'));
    });

    test('缺少 locationName 欄位時拋出 DataParsingFailure', () {
      final json = _validLocationJson()..remove('locationName');
      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('locationName 為空白字串時拋出 DataParsingFailure', () {
      final json = _validLocationJson()..['locationName'] = '   ';
      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('locationName 型別錯誤（非字串）時拋出 DataParsingFailure', () {
      final json = _validLocationJson()..['locationName'] = 12345;
      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('weatherElement 型別錯誤時拋出 DataParsingFailure', () {
      final json = _validLocationJson()..['weatherElement'] = 'not-a-list';
      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('缺少必要天氣要素（MinT）時拋出 DataParsingFailure', () {
      final json = _validLocationJson();
      final elements = List<dynamic>.from(json['weatherElement'] as List)
        ..removeWhere(
          (element) => (element as Map<String, dynamic>)['elementName'] == 'MinT',
        );
      json['weatherElement'] = elements;

      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('MinT 數值無法轉換為整數時拋出 DataParsingFailure', () {
      final json = _validLocationJson();
      final elements = (json['weatherElement'] as List<dynamic>).map((raw) {
        final element = Map<String, dynamic>.from(raw as Map<String, dynamic>);
        if (element['elementName'] == 'MinT') {
          element['time'] = (element['time'] as List<dynamic>).map((raw) {
            final time = Map<String, dynamic>.from(raw as Map<String, dynamic>);
            time['parameter'] = {'parameterName': '非數字'};
            return time;
          }).toList();
        }
        return element;
      }).toList();
      json['weatherElement'] = elements;

      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('startTime 無法解析為日期時拋出 DataParsingFailure', () {
      final json = _validLocationJson();
      final elements = (json['weatherElement'] as List<dynamic>).map((raw) {
        final element = Map<String, dynamic>.from(raw as Map<String, dynamic>);
        if (element['elementName'] == 'Wx') {
          element['time'] = (element['time'] as List<dynamic>).map((raw) {
            final time = Map<String, dynamic>.from(raw as Map<String, dynamic>);
            time['startTime'] = '不是時間格式';
            return time;
          }).toList();
        }
        return element;
      }).toList();
      json['weatherElement'] = elements;

      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });

    test('PoP（降雨機率）要素缺漏時，rainProbabilityPercent 為 null 且其餘欄位正常解析', () {
      final json = _validLocationJson();
      final elements = List<dynamic>.from(json['weatherElement'] as List)
        ..removeWhere(
          (element) => (element as Map<String, dynamic>)['elementName'] == 'PoP',
        );
      json['weatherElement'] = elements;

      final forecast = LocationForecast.fromJson(json);

      expect(forecast.periods.first.rainProbabilityPercent, isNull);
      expect(forecast.periods.first.weatherDescription, '多雲');
    });

    test('weatherElement 為空陣列時拋出 DataParsingFailure', () {
      final json = _validLocationJson()..['weatherElement'] = <dynamic>[];
      expect(
        () => LocationForecast.fromJson(json),
        throwsA(isA<DataParsingFailure>()),
      );
    });
  });
}
