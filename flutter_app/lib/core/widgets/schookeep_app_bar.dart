import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'rtl_icon.dart';

/// The 56px white top app bar with a bottom border, matching the export's
/// `<div className="h-[56px] bg-white px-4 ... border-b border-[#E2E8F0]">`.
class SchooKeepAppBar extends StatelessWidget {
  const SchooKeepAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onBack,
    this.actions = const [],
    this.centerTitle = false,
    this.backgroundColor = SchooKeepColors.surface,
  });

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool centerTitle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final titleText = titleWidget ??
        (title == null
            ? null
            : Text(
                title!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textPrimary,
                ),
              ));

    return Container(
      height: SchooKeepTheme.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            _TapTarget(
              onTap: onBack!,
              child: const RtlIcon(Icons.arrow_back_ios_new, size: 20, color: SchooKeepColors.textPrimary),
            ),
          if (onBack != null) const SizedBox(width: 4),
          Expanded(
            child: titleText == null
                ? const SizedBox.shrink()
                : Align(
                    alignment: centerTitle ? Alignment.center : AlignmentDirectional.centerStart,
                    child: titleText,
                  ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SchooKeepTheme.minTapTarget,
      height: SchooKeepTheme.minTapTarget,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SchooKeepTheme.radiusFull),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
