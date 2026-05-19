import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/routing/nav.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/board_post_style.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/screen_frame.dart';

/// Screen 19 — Noticeboard post composer (formerly "broadcast").
///
/// Brief §11/§12: a broadcast IS a board post. The owner picks a post **type**
/// (the colour/icon is derived from it — never a free colour) and the post
/// goes onto the noticeboard for everyone; a push notification is sent
/// alongside. With [editPostId] set the screen edits an existing post.
class BroadcastComposerScreen extends ConsumerStatefulWidget {
  final String? editPostId;
  const BroadcastComposerScreen({super.key, this.editPostId});

  @override
  ConsumerState<BroadcastComposerScreen> createState() =>
      _BroadcastComposerScreenState();
}

class _BroadcastComposerScreenState
    extends ConsumerState<BroadcastComposerScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _type = 'info';
  bool _pinned = false;
  bool _busy = false;

  bool get _isEdit =>
      widget.editPostId != null && widget.editPostId!.isNotEmpty;
  late bool _loading = _isEdit;

  static const _templates = [
    ('outage', 'Mimořádně zavřeno',
        'Dnes mám zavřeno, omlouvám se. Zítra zase normálně.'),
    ('promo', 'Nový stroj', 'Přibyl nový stroj. Mrkněte na nástěnku.'),
    ('warning', 'Změna otevírací doby',
        'Mění se otevírací doba. Detaily níže.'),
    ('info', 'Vánoční pauza',
        'Přes svátky bude Klub zavřený. Užijte si to.'),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadForEdit();
  }

  Future<void> _loadForEdit() async {
    final post =
        await ref.read(gymRepositoryProvider).boardPostById(widget.editPostId!);
    if (!mounted) return;
    setState(() {
      if (post != null) {
        _title.text = post.title;
        _body.text = post.body;
        _type = post.type;
        _pinned = post.pinned;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (body.isEmpty) return;
    setState(() => _busy = true);
    final repo = ref.read(gymRepositoryProvider);
    final l = L.of(context);
    if (_isEdit) {
      await repo.updateBoardPost(
        widget.editPostId!,
        type: _type,
        title: title,
        body: body,
        pinned: _pinned,
      );
    } else {
      await repo.addBoardPost(
        type: _type,
        title: title,
        body: body,
        pinned: _pinned,
      );
    }
    ref.invalidate(boardPostsProvider);
    if (!mounted) return;
    navCb(context)('back',
        toast: _isEdit ? l.bcastUpdatedToast : l.bcastPublishedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final nav = navCb(context);
    final canSend = _body.text.trim().isNotEmpty && !_busy;

    if (_loading) {
      return const ScreenFrame(
        child: Center(
            child: CircularProgressIndicator(color: T.accent)),
      );
    }

    return ScreenFrame(
      child: Column(
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                RoundIconButton(icon: 'back', onTap: () => nav('back')),
                const Spacer(),
                Text(
                    _isEdit ? l.bcastHeaderEdit : l.bcastHeaderNew,
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
                _label(l.bcastSectionType),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kComposablePostTypes.map((t) {
                    final sel = t == _type;
                    final style = boardPostStyle(t);
                    return GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Space.s14, vertical: 9),
                        decoration: BoxDecoration(
                          color: sel
                              ? style.color.withAlpha(0x22)
                              : T.surface,
                          border: Border.all(
                              color: sel ? style.color : T.border),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(style.icon,
                                size: 13,
                                stroke: 2.2,
                                color: sel ? style.color : T.text2),
                            const SizedBox(width: 6),
                            Text(boardPostLabel(context, t),
                                style: AppType.ui(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: sel ? style.color : T.text)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _label(l.bcastSectionMessage),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(Space.xs),
                  child: Column(
                    children: [
                      TextField(
                        controller: _title,
                        onChanged: (_) => setState(() {}),
                        style: AppType.ui(size: 15, weight: FontWeight.w600),
                        decoration: _dec(l.bcastTitleHint),
                      ),
                      const Divider(height: 1, color: T.divider),
                      TextField(
                        controller: _body,
                        onChanged: (_) => setState(() {}),
                        minLines: 4,
                        maxLines: 8,
                        style: AppType.ui(size: 14, height: 1.5),
                        decoration: _dec(l.bcastBodyHint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _PinToggle(
                  value: _pinned,
                  onChange: (v) => setState(() => _pinned = v),
                  label: l.bcastPin,
                  sub: l.bcastPinSub,
                ),
                const SizedBox(height: 16),
                _label(l.bcastSectionTemplates),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _templates.map((t) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        _type = t.$1;
                        _title.text = t.$2;
                        _body.text = t.$3;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Space.md, vertical: 8),
                        decoration: BoxDecoration(
                          color: T.surface,
                          border: Border.all(color: T.border),
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Text(t.$2,
                            style: AppType.ui(
                                size: 12.5,
                                weight: FontWeight.w500,
                                color: T.text2)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _label(l.bcastSectionPreview),
                const SizedBox(height: 10),
                _PreviewPost(
                  type: _type,
                  title: _title.text.trim().isEmpty
                      ? l.bcastPreviewNoTitle
                      : _title.text.trim(),
                  body: _body.text.trim().isEmpty
                      ? l.bcastPreviewBodyPlaceholder
                      : _body.text.trim(),
                ),
              ],
            ),
          ),
          // ── Send bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: T.glassBar,
              border: Border(top: BorderSide(color: T.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.bcastPushNote,
                    textAlign: TextAlign.center,
                    style: AppType.ui(size: 11.5, color: T.text3)),
                const SizedBox(height: 10),
                AppButton(
                  label: _isEdit ? l.bcastSaveEdit : l.bcastPublish,
                  full: true,
                  variant:
                      canSend ? BtnVariant.primary : BtnVariant.secondary,
                  icon: AppIcon(_isEdit ? 'check' : 'send',
                      size: 18, color: canSend ? Colors.white : T.text3),
                  onTap: !canSend ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            const EdgeInsets.symmetric(horizontal: Space.md, vertical: 12),
      );
}

class _PinToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChange;
  final String label;
  final String sub;
  const _PinToggle({
    required this.value,
    required this.onChange,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChange(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 13),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            const AppIcon('pin', size: 16, color: T.text2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppType.ui(
                          size: 14.5, weight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: AppType.ui(size: 12, color: T.text2)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 46,
              height: 28,
              padding: const EdgeInsets.all(Space.xxs),
              decoration: BoxDecoration(
                color: value ? T.accent : T.surface2,
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(
                    color: value ? Colors.transparent : T.border),
              ),
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPost extends StatelessWidget {
  final String type;
  final String title;
  final String body;
  const _PreviewPost({
    required this.type,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final style = boardPostStyle(type);
    final c = style.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Container(
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: T.border),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: Container(color: c),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.withAlpha(0x22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(style.icon, size: 11, color: c, stroke: 2.2),
                        const SizedBox(width: 6),
                        Text(
                          boardPostLabel(context, type).toUpperCase(),
                          style: AppType.ui(
                            size: 10.5,
                            weight: FontWeight.w700,
                            color: c,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: AppType.ui(
                      size: 16,
                      weight: FontWeight.w600,
                      color: T.text,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: AppType.ui(size: 13.5, color: T.text2, height: 1.5),
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
