import 'package:cwa_weather/src/features/weather/presentation/widgets/weather_icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weatherIconFor', () {
    test('含「晴」與「雲」的描述優先顯示晴天圖示', () {
      expect(weatherIconFor('晴時多雲'), Icons.wb_sunny_rounded);
      expect(weatherIconFor('多雲時晴'), Icons.wb_sunny_rounded);
    });

    test('僅含「雲」時顯示多雲圖示', () {
      expect(weatherIconFor('多雲'), Icons.wb_cloudy_rounded);
    });

    test('含「雷」時優先顯示雷雨圖示，即使同時提到雨', () {
      expect(weatherIconFor('午後短暫雷陣雨'), Icons.thunderstorm_rounded);
    });

    test('含「雨」但不含「雷」時顯示降雨圖示', () {
      expect(weatherIconFor('陰短暫陣雨'), Icons.umbrella_rounded);
    });

    test('含「陰」但不含「雲」「晴」時顯示陰天圖示', () {
      expect(weatherIconFor('陰天'), Icons.cloud_rounded);
    });

    test('無法辨識的描述回傳預設圖示', () {
      expect(weatherIconFor('未知現象'), Icons.cloud_outlined);
    });
  });
}
