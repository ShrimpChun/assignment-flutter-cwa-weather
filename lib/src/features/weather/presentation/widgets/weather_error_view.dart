import 'package:flutter/material.dart';

import '../../../../core/error/weather_failure.dart';

/// 呼叫 API 失敗時顯示的錯誤畫面，依 [failure] 顯示對應的錯誤說明文字。
class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({required this.failure, this.onRetry, super.key});

  final WeatherFailure failure;

  /// 使用者點擊「重試」按鈕時觸發；傳入 null 時不顯示重試按鈕
  /// （例如尚未輸入任何內容的情境）。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          key: const Key('weatherErrorView'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(failure),
              size: 88,
              color: colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              failure.message,
              key: const Key('weatherErrorMessage'),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重試'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(WeatherFailure failure) {
    return switch (failure) {
      InvalidInputFailure() => Icons.edit_off_rounded,
      MissingApiKeyFailure() => Icons.vpn_key_off_rounded,
      NetworkFailure() => Icons.wifi_off_rounded,
      UnauthorizedFailure() => Icons.lock_outline_rounded,
      ServerFailure() => Icons.cloud_off_rounded,
      LocationNotFoundFailure() => Icons.location_off_rounded,
      DataParsingFailure() => Icons.data_array_rounded,
      UnknownFailure() => Icons.error_outline_rounded,
    };
  }
}
