import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

/// Label → value row (detail / payment / membership panes). Replaces the
/// per-screen private `_KV`/`_DetailRow` copies. Pass [value] for plain
/// text or [valueWidget] for a pill/custom trailing.
class KVRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool mono;

  const KVRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.mono = false,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppType.label(color: T.text2)),
          const SizedBox(width: Space.lg),
          Flexible(
            child: valueWidget ??
                Text(
                  value!,
                  textAlign: TextAlign.right,
                  style: mono
                      ? AppType.mono(size: 13, weight: FontWeight.w500)
                      : AppType.label(),
                ),
          ),
        ],
      ),
    );
  }
}
