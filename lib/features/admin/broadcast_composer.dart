import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// Screen 19 — Broadcast Composer.
///
/// No JSX prototype exists in the design bundle for this screen; built to the
/// brief §4.4A (recipient selector → editor → preview → send) using the same
/// design tokens and the broadcast-sheet visual language from AdminMessages.
class BroadcastComposerScreen extends ConsumerStatefulWidget {
  const BroadcastComposerScreen({super.key});

  @override
  ConsumerState<BroadcastComposerScreen> createState() =>
      _BroadcastComposerScreenState();
}

class _BroadcastComposerScreenState
    extends ConsumerState<BroadcastComposerScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _target = 0;

  static const _templates = [
    ('Mimořádně zavřeno', 'Dnes mám zavřeno, omlouvám se. Zítra zase normálně.'),
    ('Nový stroj', 'Přibyl nový stroj. Mrkněte na nástěnku.'),
    ('Změna otevírací doby', 'Mění se otevírací doba. Detaily na nástěnce.'),
    ('Vánoční pauza', 'Přes svátky bude Klub zavřený. Užijte si to.'),
  ];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final active = store.members.where((m) => m.state != 'muted').length;
    final overdue = store.members.where((m) => m.state == 'error').length;
    final ending = store.members.where((m) => m.state == 'warn').length;
    final targets = <(String, int)>[
      ('Všem aktivním', active),
      ('Dlužníkům', overdue),
      ('Končícím', ending),
      ('Všem členům', store.members.length),
    ];
    final recipients = targets[_target].$2;
    final canSend = _body.text.trim().isNotEmpty && recipients > 0;
    final nav = navCb(context);

    return ScreenFrame(
      child: Column(
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                _RoundBtn(icon: 'back', onTap: () => nav('back')),
                const Spacer(),
                Text('Hromadná zpráva',
                    style: AppType.ui(
                        size: 14, weight: FontWeight.w600, color: T.text2)),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                _label('PŘÍJEMCI'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(targets.length, (i) {
                    final sel = i == _target;
                    return GestureDetector(
                      onTap: () => setState(() => _target = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? T.accentSoft : T.surface,
                          border: Border.all(
                              color: sel ? T.accent : T.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(targets[i].$1,
                                style: AppType.ui(
                                    size: 13.5,
                                    weight: FontWeight.w500,
                                    color: sel ? T.accent : T.text)),
                            const SizedBox(width: 6),
                            Text('${targets[i].$2}',
                                style: AppType.mono(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: sel ? T.accent : T.text3)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                _label('ZPRÁVA'),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      TextField(
                        controller: _title,
                        onChanged: (_) => setState(() {}),
                        style: AppType.ui(size: 15, weight: FontWeight.w600),
                        decoration: _dec('Titulek (volitelné)'),
                      ),
                      const Divider(height: 1, color: T.divider),
                      TextField(
                        controller: _body,
                        onChanged: (_) => setState(() {}),
                        minLines: 4,
                        maxLines: 8,
                        style: AppType.ui(size: 14, height: 1.5),
                        decoration: _dec('Napiš zprávu členům…'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _label('ŠABLONY'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _templates.map((t) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        _title.text = t.$1;
                        _body.text = t.$2;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: T.surface,
                          border: Border.all(color: T.border),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(t.$1,
                            style: AppType.ui(
                                size: 12.5,
                                weight: FontWeight.w500,
                                color: T.text2)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _label('NÁHLED'),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppIcon('megaphone',
                              size: 14, color: T.text2),
                          const SizedBox(width: 6),
                          Text('INFO · NÁSTĚNKA',
                              style: AppType.ui(
                                  size: 10.5,
                                  weight: FontWeight.w700,
                                  color: T.text3,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _title.text.trim().isEmpty
                            ? 'Bez titulku'
                            : _title.text.trim(),
                        style: AppType.ui(size: 16, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _body.text.trim().isEmpty
                            ? 'Tady se zobrazí text zprávy.'
                            : _body.text.trim(),
                        style: AppType.ui(
                            size: 13.5, color: T.text2, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Send bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: Color(0xF20F0F10),
              border: Border(top: BorderSide(color: T.border)),
            ),
            child: AppButton(
              label: 'Odeslat · $recipients '
                  '${_plural(recipients, 'člen', 'členům', 'členům')}',
              full: true,
              variant:
                  canSend ? BtnVariant.primary : BtnVariant.secondary,
              icon: AppIcon('send',
                  size: 18, color: canSend ? Colors.white : T.text3),
              onTap: !canSend
                  ? null
                  : () {
                      for (final m in _recipientsList(store)) {
                        store.sendMessage(m.id,
                            '${_title.text.trim().isEmpty ? '' : '${_title.text.trim()}\n'}${_body.text.trim()}',
                            from: 'olda');
                      }
                      nav('messages',
                          toast: 'Odesláno · $recipients členům');
                    },
            ),
          ),
        ],
      ),
    );
  }

  Iterable _recipientsList(GymStore store) {
    switch (_target) {
      case 1:
        return store.members.where((m) => m.state == 'error');
      case 2:
        return store.members.where((m) => m.state == 'warn');
      case 3:
        return store.members;
      default:
        return store.members.where((m) => m.state != 'muted');
    }
  }

  String _plural(int n, String one, String few, String many) =>
      n == 1 ? one : (n >= 2 && n <= 4 ? few : many);

  Widget _label(String s) => Text(s,
      style: AppType.ui(
          size: 11.5,
          weight: FontWeight.w600,
          color: T.text2,
          letterSpacing: 0.4));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppType.ui(size: 14, color: T.text3),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}

class _RoundBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.surface,
          shape: BoxShape.circle,
          border: Border.all(color: T.border),
        ),
        child: AppIcon(icon, size: 18, color: T.text),
      ),
    );
  }
}
