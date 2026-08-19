import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/taiwan_locations.dart';
import '../providers/weather_notifier.dart';
import '../state/weather_ui_state.dart';
import '../widgets/weather_error_view.dart';
import '../widgets/weather_initial_view.dart';
import '../widgets/weather_loading_view.dart';
import '../widgets/weather_result_view.dart';
import '../widgets/weather_search_bar.dart';

/// 應用程式主畫面：上方為搜尋欄，下方依查詢狀態顯示四種畫面之一。
class WeatherHomeScreen extends ConsumerStatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  ConsumerState<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends ConsumerState<WeatherHomeScreen> {
  final _controller = TextEditingController();

  /// 最近一次實際送出查詢（或下拉刷新）的地區名稱，用於錯誤畫面的
  /// 「重試」按鈕。刻意不直接讀取 [_controller] 目前的內容──使用者
  /// 可能在查詢成功後修改了輸入框文字卻未按下確認，此時輸入框內容
  /// 已經與畫面上顯示（或查詢失敗）的地區脫勾。
  String? _lastAttemptedLocation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    FocusScope.of(context).unfocus();
    final locationName = value.trim();
    _lastAttemptedLocation = locationName.isEmpty ? null : locationName;
    ref.read(weatherNotifierProvider.notifier).search(value);
  }

  Future<void> _refresh(String locationName) {
    _lastAttemptedLocation = locationName;
    return ref.read(weatherNotifierProvider.notifier).refresh(locationName);
  }

  void _clear() {
    _controller.clear();
    _lastAttemptedLocation = null;
    ref.read(weatherNotifierProvider.notifier).reset();
  }

  void _selectSuggestion(String locationName) {
    _controller
      ..text = locationName
      ..selection = TextSelection.collapsed(offset: locationName.length);
    _search(locationName);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherNotifierProvider);
    final isLoading = state is WeatherLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('中央氣象署天氣預報')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              WeatherSearchBar(
                controller: _controller,
                isLoading: isLoading,
                onSearch: _search,
                onClear: _clear,
              ),
              const SizedBox(height: 12),
              _LocationSuggestions(
                enabled: !isLoading,
                onSelected: _selectSuggestion,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildContent(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherUiState state) {
    return switch (state) {
      WeatherInitial() => const WeatherInitialView(key: ValueKey('initial')),
      WeatherLoading() => const WeatherLoadingView(key: ValueKey('loading')),
      WeatherSuccess(:final forecast) => WeatherResultView(
        key: ValueKey('result-${forecast.locationName}'),
        forecast: forecast,
        onRefresh: () => _refresh(forecast.locationName),
      ),
      WeatherError(:final failure) => WeatherErrorView(
        key: ValueKey('error-${failure.message}'),
        failure: failure,
        onRetry: _lastAttemptedLocation == null
            ? null
            : () => _search(_lastAttemptedLocation!),
      ),
    };
  }
}

class _LocationSuggestions extends StatelessWidget {
  const _LocationSuggestions({required this.enabled, required this.onSelected});

  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kTaiwanLocations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final locationName = kTaiwanLocations[index];
          return ActionChip(
            label: Text(locationName),
            onPressed: enabled ? () => onSelected(locationName) : null,
          );
        },
      ),
    );
  }
}
