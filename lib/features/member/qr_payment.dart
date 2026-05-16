import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/qr_code.dart';
import '../../shared/widgets/screen_frame.dart';

/// A selectable membership tariff (QRPayment.jsx `TARIFFS`).
class _Tariff {
  final String id;
  final String title;
  final int months;
  final int price;
  final String vs;
  final String? saving;
  final int seed;
  const _Tariff({
    required this.id,
    required this.title,
    required this.months,
    required this.price,
    required this.vs,
    required this.saving,
    required this.seed,
  });
}

const List<_Tariff> _kTariffs = [
  _Tariff(
      id: 'm1',
      title: '1 měsíc',
      months: 1,
      price: 850,
      vs: '260001',
      saving: null,
      seed: 1),
  _Tariff(
      id: 'm3',
      title: '3 měsíce',
      months: 3,
      price: 2250,
      vs: '260003',
      saving: 'ušetříš 300 Kč',
      seed: 3),
  _Tariff(
      id: 'm6',
      title: '6 měsíců',
      months: 6,
      price: 4250,
      vs: '260006',
      saving: 'ušetříš 850 Kč',
      seed: 6),
];

/// QR Payment 05 — interactive tariff picker + SPAYD QR + payment details.
/// Pixel port of QRPayment.jsx.
class QrPaymentScreen extends ConsumerStatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  ConsumerState<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends ConsumerState<QrPaymentScreen> {
  // JSX default is 'm3'; pick index of 'm3' if present, else 0.
  late int _selected = () {
    final i = _kTariffs.indexWhere((t) => t.id == 'm3');
    return i < 0 ? 0 : i;
  }();

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);
    final t = _kTariffs[_selected];

    return ScreenFrame(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back + title.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
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
                    child: Center(
                      child: Text(
                        L.of(context).qrTitle,
                        style: AppType.ui(
                          size: 14,
                          weight: FontWeight.w600,
                          color: T.text2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tariff label.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      L.of(context).qrTariffLabel,
                      style: AppType.ui(
                        size: 13,
                        weight: FontWeight.w600,
                        color: T.text2,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  // Tariff grid — flexible (2–6 tiles), rendered from the list.
                  LayoutBuilder(
                    builder: (context, c) {
                      const gap = 8.0;
                      final count = _kTariffs.length;
                      final tileW =
                          (c.maxWidth - gap * (count - 1)) / count;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < count; i++) ...[
                              if (i > 0) const SizedBox(width: gap),
                              SizedBox(
                                width: tileW,
                                child: _TariffPick(
                                  tariff: _kTariffs[i],
                                  active: i == _selected,
                                  onTap: () =>
                                      setState(() => _selected = i),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  // Headline.
                  Text(
                    L.of(context).qrHeadline,
                    style: AppType.ui(
                      size: 22,
                      weight: FontWeight.w700,
                      color: T.text,
                      letterSpacing: -0.6,
                      height: 1.2,
                    ),
                  ),

                  // QR card (white).
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(Space.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Radii.s18),
                    ),
                    child: Column(
                      children: [
                        QrCode(size: 224, seed: t.seed),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'SPAYD · ${kc(t.price)} · VS ${t.vs}',
                            style: AppType.mono(
                              size: 11,
                              weight: FontWeight.w500,
                              color: T.bg,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment details.
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _DetailRow(
                            label: L.of(context).qrDetailAmount,
                            value: kc(t.price),
                            big: true,
                          ),
                          _DetailRow(
                            label: L.of(context).qrDetailAccount,
                            value: '1234567890 / 0100',
                            mono: true,
                          ),
                          _DetailRow(
                            label: L.of(context).qrDetailVs,
                            value: t.vs,
                            mono: true,
                          ),
                          _DetailRow(
                            label: L.of(context).qrDetailMessage,
                            value: 'Členství Pavel Novák · ${t.title}',
                            mono: true,
                            last: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save / Copy.
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GhostBtn(
                            icon: AppIcon('download', size: 16, color: T.text),
                            label: L.of(context).qrSaveQr,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _GhostBtn(
                            icon: AppIcon('copy', size: 16, color: T.text),
                            label: L.of(context).qrCopy,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hint.
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child:
                              AppIcon('alert', size: 12, color: T.text3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            L.of(context).qrSaveHint,
                            style: AppType.ui(
                              size: 12,
                              color: T.text3,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "Zaplatil jsem" — confirm + back to dashboard with toast.
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: T.accent,
                        borderRadius: BorderRadius.circular(Radii.lg),
                        child: InkWell(
                          onTap: () => nav('dashboard',
                              toast: L.of(context).qrToastMarkedPaid),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: Text(
                              L.of(context).qrPaidButton,
                              style: AppType.ui(
                                size: 16,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

/// One tariff tile (QRPayment.jsx `TariffPick`).
class _TariffPick extends StatelessWidget {
  final _Tariff tariff;
  final bool active;
  final VoidCallback onTap;
  const _TariffPick({
    required this.tariff,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: active ? T.accentSoft : T.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: active ? T.accent : T.border),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tariff.title,
                  style: AppType.ui(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: active ? T.accent : T.text2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    kc(tariff.price),
                    style: AppType.mono(
                      size: 15,
                      weight: FontWeight.w700,
                      color: T.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (tariff.saving != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tariff.saving!,
                      style: AppType.ui(
                        size: 10,
                        weight: FontWeight.w500,
                        color: T.ok,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
            if (active)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: T.accent,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon('check',
                      size: 9, color: Colors.white, stroke: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A row in the payment-details card (QRPayment.jsx `DetailRow`).
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool big;
  final bool last;
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.big = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = (mono || big)
        ? AppType.mono(
            size: big ? 18 : 14,
            weight: big ? FontWeight.w700 : FontWeight.w500,
            color: T.text,
            letterSpacing: big ? -0.5 : 0,
          )
        : AppType.ui(
            size: 14,
            weight: FontWeight.w500,
            color: T.text,
            letterSpacing: 0,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: T.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppType.ui(size: 13.5, color: T.text2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ghost button matching shared.jsx Btn ghost (transparent, border, r14).
class _GhostBtn extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const _GhostBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: T.border),
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.ui(
                    size: 16,
                    weight: FontWeight.w600,
                    color: T.text,
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
