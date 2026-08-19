import 'package:flutter/material.dart';

/// 「未查詢」「查詢中」「查詢失敗」三種訊息型畫面共用的版面骨架：
/// 置中的視覺焦點（圖示或載入指示器）＋標題文字＋可選的輔助說明與操作按鈕。
///
/// 抽出此共用元件是為了避免三個畫面各自複製一份幾乎相同的
/// 「Center > Padding > Column」排版邏輯，未來調整間距、留白等
/// 版面細節時只需要修改一處。
class WeatherStatusMessage extends StatelessWidget {
  const WeatherStatusMessage({
    required this.visual,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.action,
    super.key,
  });

  /// 版面最上方的視覺焦點，例如 [Icon] 或 [CircularProgressIndicator]。
  final Widget visual;

  /// 主要說明文字。
  final String title;

  /// [title] 的文字樣式；未提供時使用粗體的 `titleLarge`。
  final TextStyle? titleStyle;

  /// 補充說明文字，可省略。
  final String? subtitle;

  /// 操作按鈕（例如「重試」），可省略。
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            const SizedBox(height: 20),
            Text(
              title,
              style:
                  titleStyle ??
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
