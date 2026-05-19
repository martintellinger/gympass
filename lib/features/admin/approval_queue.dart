import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/utils/app_toast.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';

/// Approval Queue 13 — schvalování nových registrací.
///
/// 1:1 port of docs/design/gympass/project/screens/ApprovalQueue.jsx.
/// The JSX shows a single applicant detail with a "1 / 2" counter implying a
/// local queue. We hold the sample applicants in local state; approve/reject
/// removes the current one and (when the queue empties) navigates back to admin
/// with a toast.
class ApprovalQueueScreen extends ConsumerStatefulWidget {
  const ApprovalQueueScreen({super.key});

  @override
  ConsumerState<ApprovalQueueScreen> createState() =>
      _ApprovalQueueScreenState();
}

class _Applicant {
  final String name;
  final String shortName;
  final String submitted;
  final String email;
  final String phone;
  final String tarif;
  final String pill;
  final String gdpr;
  final String isicMeta;
  final String isicUpload;
  final String isicCheck;
  final String note;

  const _Applicant({
    required this.name,
    required this.shortName,
    required this.submitted,
    required this.email,
    required this.phone,
    required this.tarif,
    required this.pill,
    required this.gdpr,
    required this.isicMeta,
    required this.isicUpload,
    required this.isicCheck,
    required this.note,
  });
}

class _ApprovalQueueScreenState extends ConsumerState<ApprovalQueueScreen> {
  static String _short(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length < 2) return name;
    return '${p.first} ${p[1][0]}.';
  }

  _Applicant _toApplicant(Member m) => _Applicant(
        name: m.name,
        shortName: _short(m.name),
        submitted: '',
        email: m.email == '—' ? '' : m.email,
        phone: m.phone == '—' ? '' : m.phone,
        tarif: m.tariff,
        pill: m.isic ? 'ISIC' : '',
        gdpr: '',
        isicMeta: '',
        isicUpload: '',
        isicCheck: '',
        note: '',
      );

  Future<void> _decide({
    required String id,
    required bool approve,
    required String toast,
  }) async {
    final repo = ref.read(gymRepositoryProvider);
    if (approve) {
      await repo.approveMember(id);
    } else {
      await repo.rejectMember(id);
    }
    ref.invalidate(pendingMembersProvider);
    ref.invalidate(membersProvider);
    if (mounted) showAppToast(context, toast);
  }

  Widget _emptyState(BuildContext context, NavCb nav) {
    final l = L.of(context);
    return ScreenFrame(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => nav('back'),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: AppIcon('back', size: 20, color: T.text),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: T.okSoft,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child:
                          const AppIcon('check', size: 26, color: T.ok),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.apprEmptyTitle,
                      textAlign: TextAlign.center,
                      style: AppType.ui(
                        size: 16,
                        weight: FontWeight.w700,
                        color: T.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.apprEmptyBody,
                      textAlign: TextAlign.center,
                      style: AppType.ui(
                        size: 13.5,
                        color: T.text2,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);
    final pendingAsync = ref.watch(pendingMembersProvider);

    if (pendingAsync.isLoading && !pendingAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 5),
        ),
      );
    }
    if (pendingAsync.hasError && !pendingAsync.hasValue) {
      return ScreenFrame(
        child: LoadError(
            onRetry: () => ref.invalidate(pendingMembersProvider)),
      );
    }
    final members = pendingAsync.value ?? const <Member>[];
    if (members.isEmpty) return _emptyState(context, nav);

    final current = members.first;
    final a = _toApplicant(current);
    final total = members.length;
    const pos = 1;

    return ScreenFrame(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => nav('back'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: T.surface,
                      border: Border.all(color: T.border),
                    ),
                    alignment: Alignment.center,
                    child: AppIcon('back', size: 18, color: T.text),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L.of(context).apprTitle,
                        style: AppType.ui(
                          size: 14,
                          weight: FontWeight.w600,
                          color: T.text2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$pos / $total',
                        style: AppType.mono(
                          size: 11,
                          color: T.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L.of(context).apprNewApplicant,
                            style: AppType.ui(
                              size: 13,
                              weight: FontWeight.w600,
                              color: T.accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.name,
                            style: AppType.ui(
                              size: 26,
                              weight: FontWeight.w700,
                              color: T.text,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.submitted,
                            style: AppType.mono(
                              size: 13,
                              color: T.text2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details card
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _kv2(label: L.of(context).apprEmail, value: a.email),
                          _divider(),
                          _kv2(
                              label: L.of(context).apprPhone,
                              value: a.phone,
                              mono: true),
                          _divider(),
                          _kv2(
                            label: L.of(context).apprTariff,
                            value: a.tarif,
                            pill: a.pill.isEmpty ? null : a.pill,
                          ),
                          _divider(),
                          _kv2(
                            label: L.of(context).apprGdprConsent,
                            value: a.gdpr,
                            tinyMono: true,
                            last: true,
                          ),
                        ],
                      ),
                    ),

                    // ISIC
                    const SizedBox(height: 20),
                    Text(
                      L.of(context).apprIsicCard,
                      style: AppType.ui(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: T.text2,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.lg),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: T.cardSheenRaised,
                          ),
                          border: Border.all(color: T.border),
                          borderRadius: BorderRadius.circular(Radii.lg),
                        ),
                        child: Stack(
                          children: [
                            // diagonal hatch placeholder
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _HatchPainter(),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Text(
                                a.isicUpload,
                                style: AppType.mono(
                                  size: 10,
                                  color: T.text3,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              bottom: 12,
                              child: DottedBorderBox(
                                color: T.border,
                                radius: 10,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppIcon('isic',
                                          size: 36, color: T.text3),
                                      const SizedBox(height: 8),
                                      Text(
                                        a.isicMeta,
                                        style: AppType.mono(
                                          size: 12,
                                          color: T.text3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Space.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: T.scrimMedium,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  L.of(context).apprTapToEnlarge,
                                  style: AppType.mono(
                                    size: 10.5,
                                    color: T.text,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Space.md, vertical: 10),
                      decoration: BoxDecoration(
                        color: T.warnSoft,
                        borderRadius: BorderRadius.circular(Radii.s10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child:
                                AppIcon('alert', size: 14, color: T.warn),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: L.of(context).apprCheckPrefix,
                                    style: AppType.ui(
                                      size: 12.5,
                                      weight: FontWeight.w600,
                                      color: T.warn,
                                      height: 1.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: a.isicCheck,
                                    style: AppType.ui(
                                      size: 12.5,
                                      color: T.text2,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Note from applicant
                    const SizedBox(height: 20),
                    Text(
                      L.of(context).apprApplicantNote,
                      style: AppType.ui(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: T.text2,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(Space.s14),
                      decoration: BoxDecoration(
                        color: T.surface,
                        border: Border.all(color: T.border),
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Text(
                        a.note,
                        style: AppType.ui(
                          size: 14,
                          color: T.text,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sticky action bar
          Container(
            decoration: const BoxDecoration(
              color: T.glassBar,
              border: Border(top: BorderSide(color: T.border)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Row(
              children: [
                Expanded(
                  flex: 100,
                  child: _ActionButton(
                    label: L.of(context).apprReject,
                    ghost: true,
                    fg: T.error,
                    borderColor: const Color(0x4DFF3B30), // rgba(255,59,48,0.3)
                    onTap: () => _decide(
                        id: current.id,
                        approve: false,
                        toast: L.of(context).apprRejectedToast(a.shortName)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 160,
                  child: _ActionButton(
                    label: L.of(context).apprApprove,
                    ghost: false,
                    fg: Colors.white,
                    bg: T.accent,
                    icon: AppIcon('check', size: 18, color: Colors.white),
                    onTap: () => _decide(
                        id: current.id,
                        approve: true,
                        toast: L.of(context).apprApprovedToast(a.shortName)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: T.divider);

  Widget _kv2({
    required String label,
    required String value,
    bool mono = false,
    String? pill,
    bool tinyMono = false,
    bool last = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppType.ui(size: 13, color: T.text2),
            ),
          ),
          if (pill != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.s6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: T.border),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                pill,
                style: AppType.ui(
                  size: 10,
                  weight: FontWeight.w700,
                  color: T.text2,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            value,
            style: (mono || tinyMono)
                ? AppType.mono(
                    size: tinyMono ? 12.5 : 14,
                    weight: FontWeight.w500,
                    color: tinyMono ? T.text2 : T.text,
                  )
                : AppType.ui(
                    size: tinyMono ? 12.5 : 14,
                    weight: FontWeight.w500,
                    color: tinyMono ? T.text2 : T.text,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Action bar button — matches the JSX inline-styled Btn (height 52, r14,
/// 16/600). Built locally so the ghost variant can carry a custom border
/// color + foreground color exactly as the JSX overrides them.
class _ActionButton extends StatelessWidget {
  final String label;
  final bool ghost;
  final Color fg;
  final Color? bg;
  final Color? borderColor;
  final Widget? icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.ghost,
    required this.fg,
    required this.onTap,
    this.bg,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ghost ? Colors.transparent : (bg ?? T.surface2),
      borderRadius: BorderRadius.circular(Radii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: ghost
                ? Border.all(color: borderColor ?? T.border)
                : null,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.ui(
                    size: 16,
                    weight: FontWeight.w600,
                    color: fg,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diagonal hatch fill — 8px tile, 4px wide bar, rotated 45°,
/// rgba(255,255,255,0.03). Mirrors the SVG `<pattern>` in the JSX.
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x08FFFFFF); // ~0.03 alpha
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // Rotate the whole canvas 45° around center to mimic patternTransform.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.7853981633974483); // 45°
    canvas.translate(-size.width / 2, -size.height / 2);
    final diag = size.width + size.height;
    // 8px tile: 4px painted bar + 4px gap.
    for (double x = -diag; x < diag * 2; x += 8) {
      canvas.drawRect(
        Rect.fromLTWH(x, -diag, 4, diag * 3),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Inset dashed border box (border: 1px dashed T.border, radius 10),
/// matching the JSX absolute inset:12 dashed frame.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
          metric.extractPath(dist, next.clamp(0, metric.length)),
          paint,
        );
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
