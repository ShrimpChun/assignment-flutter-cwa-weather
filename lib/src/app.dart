import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/weather/presentation/screens/weather_home_screen.dart';

/// 應用程式根 Widget。
class CwaWeatherApp extends StatelessWidget {
  const CwaWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中央氣象署天氣預報',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const WeatherHomeScreen(),
    );
  }
}
