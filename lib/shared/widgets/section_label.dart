import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Uppercase section header repeated as a private `_SectionLabel` in many
/// screens. Optional trailing widget (a "see all" link, count, etc.).
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text.toUpperCase(), style: AppType.overline()),
        ?trailing,
      ],
    );
  }
}
