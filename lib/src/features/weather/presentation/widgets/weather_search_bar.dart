import 'package:flutter/material.dart';

/// 主畫面上方的搜尋欄位，左側為文字輸入框，右側為「確認」按鈕。
class WeatherSearchBar extends StatelessWidget {
  const WeatherSearchBar({
    required this.controller,
    required this.onSearch,
    required this.isLoading,
    super.key,
  });

  final TextEditingController controller;

  /// 使用者點擊確認按鈕或於鍵盤按下搜尋鍵時觸發，帶入目前輸入框內容。
  final ValueChanged<String> onSearch;

  /// 查詢進行中時停用輸入與按鈕，避免重複送出請求。
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('weatherSearchField'),
            controller: controller,
            enabled: !isLoading,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              hintText: '輸入地區名稱，例如：臺北市',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    tooltip: '清除',
                    onPressed: isLoading ? null : controller.clear,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          key: const Key('weatherSearchConfirmButton'),
          onPressed: isLoading ? null : () => onSearch(controller.text),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('確認'),
        ),
      ],
    );
  }
}
