import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/status_pill.dart';

/// Member Card 09 — fullscreen membership card (Apple Wallet style).
/// Port of docs/design/gympass/project/screens/MemberCard.jsx.
class MemberCardScreen extends ConsumerWidget {
  const MemberCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = navCb(context);
    final store = ref.watch(storeProvider);
    final member = store.memberById('pavel');

    final name = member?.name ?? 'Pavel Novák';
    final joined = member?.joined ?? '9 · 2025';
    final expiresAt = member?.expiresAt ?? '23. 6. 2026';
    final tariff = member?.tariff ?? 'Standard';
    final hasKey = member?.hasKey ?? true;
    final state = statusFromKey(member?.state ?? 'ok');

    // JSX: "člen od 9 · 2025" — joined string is "M · YYYY".
    final joinedLabel = 'člen od $joined';

    return ScreenFrame(
      child: Stack(
        children: [
          // Scrollable body. JSX page background is pure black (#000).
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Stack(
                  children: [
                    Padding(
                      // JSX: padding 8px 20px 40px.
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The card. marginTop 12.
                          const SizedBox(height: 12),
                          _MembershipCard(
                            name: name,
                            joinedLabel: joinedLabel,
                            expiresAt: expiresAt,
                            tariff: tariff,
                            hasKey: hasKey,
                            statusState: state,
                          ),
                          // Brightness tip. marginTop 20.
                          const SizedBox(height: 20),
                          _BrightnessTip(),
                          // Apple/Google Wallet button (UI only, fáze 2).
                          const SizedBox(height: 20),
                          const _WalletButton(),
                        ],
                      ),
                    ),
                    // Close button — absolute top 60, right 20.
                    // Status bar (~44px) is rendered above this Stack by
                    // ScreenFrame, so subtract that from the JSX top:60.
                    Positioned(
                      top: 60 - 44,
                      right: 20,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => nav('dashboard'),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const AppIcon('x', size: 16, color: T.text),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Floating bottom nav — active: 1 (Karta).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemberBottomNav(active: 1, onNav: nav),
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final String name;
  final String joinedLabel;
  final String expiresAt;
  final String tariff;
  final bool hasKey;
  final StatusState statusState;

  const _MembershipCard({
    required this.name,
    required this.joinedLabel,
    required this.expiresAt,
    required this.tariff,
    required this.hasKey,
    required this.statusState,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF161618), Color(0xFF0E0E10)],
          ),
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // Accent corner glow — top -80, right -80, 260x260 radial.
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x38FF4D2E), Color(0x00FF4D2E)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BÝTFIT',
                              style: AppType.ui(
                                size: 11,
                                weight: FontWeight.w700,
                                color: T.text2,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Členská karta',
                              style: AppType.ui(
                                size: 11,
                                weight: FontWeight.w400,
                                color: T.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: T.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon('dumbbell',
                            size: 18, color: T.accent),
                      ),
                    ],
                  ),
                  // Name. marginTop 32.
                  const SizedBox(height: 32),
                  Text(
                    name,
                    style: AppType.ui(
                      size: 26,
                      weight: FontWeight.w700,
                      color: T.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    joinedLabel,
                    style: AppType.mono(
                      size: 13,
                      weight: FontWeight.w400,
                      color: T.text2,
                    ),
                  ),
                  // Status grid. marginTop 28, 2 columns, gap 16.
                  const SizedBox(height: 28),
                  _StatusGrid(
                    expiresAt: expiresAt,
                    tariff: tariff,
                    hasKey: hasKey,
                    statusState: statusState,
                  ),
                  // Barcode strip. marginTop 28.
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
                      border: Border.all(color: T.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 220,
                      height: 40,
                      child: CustomPaint(painter: _BarcodePainter()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'BF-PN-260623',
                      style: AppType.mono(
                        size: 11,
                        weight: FontWeight.w400,
                        color: T.text3,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  final String expiresAt;
  final String tariff;
  final bool hasKey;
  final StatusState statusState;

  const _StatusGrid({
    required this.expiresAt,
    required this.tariff,
    required this.hasKey,
    required this.statusState,
  });

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: AppType.ui(
          size: 10.5,
          weight: FontWeight.w700,
          color: T.text3,
          letterSpacing: 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget label, Widget value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [label, const SizedBox(height: 6), value],
        );

    final keyValue = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon('key', size: 14, color: T.text2),
        const SizedBox(width: 6),
        Text(
          hasKey ? 'u tebe' : 'na recepci',
          style: AppType.ui(
            size: 15,
            weight: FontWeight.w600,
            color: T.text,
          ),
        ),
      ],
    );

    final valueStyle = AppType.ui(
      size: 15,
      weight: FontWeight.w600,
      color: T.text,
    );
    final monoValueStyle = AppType.mono(
      size: 15,
      weight: FontWeight.w600,
      color: T.text,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: cell(
                _label('Stav'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusPill(state: statusState, label: 'Aktivní'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: cell(
                _label('Platí do'),
                Text(expiresAt, style: monoValueStyle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: cell(
                _label('Tarif'),
                Text('$tariff · 3 měs.', style: valueStyle),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: cell(_label('Klíč'), keyValue),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  // JSX: 60 bars, x = i*3.6, widths cycle [1,1.4,2,1,2.4,1.2], full height,
  // fill #F5F5F7.
  static const _widths = [1.0, 1.4, 2.0, 1.0, 2.4, 1.2];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF5F5F7);
    for (var i = 0; i < 60; i++) {
      final x = i * 3.6;
      final w = _widths[i % 6];
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrightnessTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: AppIcon('alert', size: 14, color: T.text3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Když ukazuješ kartu Oldovi, zvyš jas obrazovky — čte se to líp.',
              style: AppType.ui(
                size: 12.5,
                weight: FontWeight.w400,
                color: T.text2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Apple/Google Wallet button — UI only, inactive (fáze 2). Not present in
/// the JSX; added per the screen brief as a disabled affordance.
class _WalletButton extends StatelessWidget {
  const _WalletButton();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon('wallet', size: 18, color: T.text),
            const SizedBox(width: 10),
            Text(
              'Přidat do Walletu',
              style: AppType.ui(
                size: 15,
                weight: FontWeight.w600,
                color: T.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
