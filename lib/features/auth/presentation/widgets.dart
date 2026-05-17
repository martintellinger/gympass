import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/screen_frame.dart';

/// Shared shell for the three auth screens (01–03): dark frame, brand mark,
/// title/subtitle, scrollable body. Keeps the screens visually identical.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIcon('dumbbell', size: 40, color: T.accent),
            const SizedBox(height: 20),
            Text(title, style: AppType.ui(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: AppType.ui(size: 15, color: T.text2)),
            const SizedBox(height: 28),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Labeled boxed text input matching the prototype's surface fields.
class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool enabled;
  final String? autofillHint;
  final TextCapitalization capitalization;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.enabled = true,
    this.autofillHint,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppType.ui(
                  size: 13, weight: FontWeight.w500, color: T.text2)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: T.border),
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscure,
              keyboardType: keyboardType,
              textCapitalization: capitalization,
              autofillHints:
                  autofillHint == null ? null : [autofillHint!],
              style: AppType.ui(size: 15, weight: FontWeight.w500),
              cursorColor: T.accent,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: Space.md, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline error banner (red-soft pill), shared by all auth screens.
class AuthError extends StatelessWidget {
  final String? message;
  const AuthError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: Space.md, vertical: 12),
        decoration: BoxDecoration(
          color: T.errorSoft,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            const AppIcon('alert', size: 18, color: T.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message!,
                  style: AppType.ui(size: 13.5, color: T.error)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text-button style link row ("No account yet? Register").
class AuthLinkRow extends StatelessWidget {
  final String lead;
  final String linkLabel;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.lead,
    required this.linkLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(lead, style: AppType.ui(size: 14, color: T.text2)),
              const SizedBox(width: 6),
              Text(linkLabel,
                  style: AppType.ui(
                      size: 14,
                      weight: FontWeight.w600,
                      color: T.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
