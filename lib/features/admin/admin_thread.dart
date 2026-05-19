import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/status_pill.dart';
import '../../l10n/app_localizations.dart';

/// Admin Thread 16 — jedna konverzace majitel ↔ člen.
/// Bubliny zpráv, kompozér, rychlé šablony, hlavička s kontextem.
class AdminThreadScreen extends ConsumerStatefulWidget {
  final String memberId;
  const AdminThreadScreen({super.key, required this.memberId});

  @override
  ConsumerState<AdminThreadScreen> createState() => _AdminThreadScreenState();
}

class _AdminThreadScreenState extends ConsumerState<AdminThreadScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastLen = -1;

  @override
  void initState() {
    super.initState();
    // Označit přečtené při otevření.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(gymRepositoryProvider)
          .markOwnerThreadRead(widget.memberId);
      if (mounted) ref.invalidate(ownerThreadProvider(widget.memberId));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(Member member) async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    await ref
        .read(gymRepositoryProvider)
        .sendOwnerMessage(member.id, t, from: 'olda');
    if (mounted) ref.invalidate(ownerThreadProvider(member.id));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);

    final mAsync = ref.watch(memberByIdProvider(widget.memberId));
    if (mAsync.isLoading && !mAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 5),
        ),
      );
    }
    if ((mAsync.hasError || mAsync.value == null) && !mAsync.isLoading) {
      return ScreenFrame(
        child: LoadError(
            onRetry: () =>
                ref.invalidate(memberByIdProvider(widget.memberId))),
      );
    }
    final member = mAsync.value!;
    final msgs = ref.watch(ownerThreadProvider(member.id)).value ??
        const <Message>[];

    if (_lastLen != msgs.length) {
      _lastLen = msgs.length;
      _scrollToEnd();
    }

    final firstName = member.name.split(' ').first;
    final state = statusFromKey(member.state);
    final hasText = _ctrl.text.trim().isNotEmpty;

    // Šablony podle stavu člena.
    final templates = <String>[];
    if (member.state == 'error') {
      templates.add(L.of(context).athrTemplatePaymentReminder(
          member.tariff == 'Student' ? '1 500' : '2 250'));
    }
    if (member.state == 'warn') {
      templates.add(L.of(context).athrTemplateExpiringSoon(firstName));
    }
    templates.add(L.of(context).athrTemplateDropBy);
    templates.add(L.of(context).athrTemplateThanksGot);

    // Bubliny seskupené po dnech.
    final groups = <_DayGroup>[];
    final Map<String, _DayGroup> map = {};
    for (final m in msgs) {
      final d = m.at;
      final key = '${d.year}-${d.month}-${d.day}';
      var g = map[key];
      if (g == null) {
        g = _DayGroup(d);
        map[key] = g;
        groups.add(g);
      }
      g.items.add(m);
    }

    final showContext = member.state == 'error' || member.state == 'warn';

    return ScreenFrame(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: T.divider, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => nav('back'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: T.surface,
                    ),
                    foregroundDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: T.border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon('back', size: 18, color: T.text),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => nav('detail', arg: member.id),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Avatar(name: member.name, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.ui(
                                  size: 14.5,
                                  weight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  StatusDot(state: state, size: 5),
                                  const SizedBox(width: 6),
                                  Text(
                                    member.tariff,
                                    style: AppType.ui(
                                        size: 11.5, color: T.text2),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('·',
                                      style: AppType.ui(
                                          size: 11.5, color: T.text3)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      member.expiresAt,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppType.mono(
                                          size: 11.5, color: T.text2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => nav('detail', arg: member.id),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: AppIcon('more', size: 18, color: T.text2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kontextová lišta (volitelná upozornění)
          if (showContext)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 10),
              decoration: BoxDecoration(
                color: member.state == 'error' ? T.errorSoft : T.warnSoft,
                borderRadius: BorderRadius.circular(Radii.s10),
              ),
              child: Row(
                children: [
                  AppIcon('alert',
                      size: 14,
                      stroke: 2.2,
                      color: member.state == 'error' ? T.error : T.warn),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      member.state == 'error'
                          ? L.of(context).athrContextOverdue
                          : L.of(context).athrExpiresIn(member.daysNum),
                      style: AppType.ui(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: member.state == 'error' ? T.error : T.warn,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Zprávy
          Expanded(
            child: groups.isEmpty
                ? Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      L.of(context).athrEmptyState,
                      style: AppType.ui(size: 13, color: T.text3),
                    ),
                  )
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    children: [
                      for (final g in groups) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                          child: Center(
                            child: Text(
                              fmtRelDay(g.date).toUpperCase(),
                              style: AppType.mono(
                                size: 11,
                                color: T.text3,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        for (var i = 0; i < g.items.length; i++)
                          _Bubble(
                            msg: g.items[i],
                            prev: i > 0 ? g.items[i - 1] : null,
                            next: i < g.items.length - 1
                                ? g.items[i + 1]
                                : null,
                          ),
                      ],
                    ],
                  ),
          ),

          // Šablony
          SizedBox(
            height: 49,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              children: [
                for (var i = 0; i < templates.length; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i == templates.length - 1 ? 0 : 6),
                    child: GestureDetector(
                      onTap: () {
                        _ctrl.text = templates[i];
                        _ctrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: _ctrl.text.length),
                        );
                        setState(() {});
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 240),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Space.md, vertical: 7),
                        decoration: BoxDecoration(
                          color: T.surface,
                          borderRadius: BorderRadius.circular(Radii.pill),
                          border: Border.all(color: T.border, width: 1),
                        ),
                        child: Text(
                          templates[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(size: 12.5, color: T.text2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Kompozér
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      color: T.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: T.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.md, vertical: 6),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(member),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      cursorColor: T.accent,
                      style: AppType.ui(
                          size: 14.5, color: T.text, height: 1.4),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 6),
                        border: InputBorder.none,
                        hintText: L.of(context).athrComposerHint(firstName),
                        hintStyle: AppType.ui(
                            size: 14.5, color: T.text3, height: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: hasText ? () => _send(member) : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasText ? T.accent : T.surface2,
                    ),
                    alignment: Alignment.center,
                    child: AppIcon('send',
                        size: 18,
                        color: hasText ? Colors.white : T.text3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup {
  final DateTime date;
  final List<Message> items = [];
  _DayGroup(this.date);
}

class _Bubble extends StatelessWidget {
  final Message msg;
  final Message? prev;
  final Message? next;
  const _Bubble({required this.msg, this.prev, this.next});

  @override
  Widget build(BuildContext context) {
    final isOlda = msg.from == 'olda';
    final prevSame = prev != null && prev!.from == msg.from;
    final nextSame = next != null && next!.from == msg.from;
    final top = prevSame ? 4.0 : 18.0;

    return Padding(
      padding: EdgeInsets.only(top: top - 6),
      child: Row(
        mainAxisAlignment:
            isOlda ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Column(
              crossAxisAlignment: isOlda
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isOlda ? T.accent : T.surface,
                    border: isOlda
                        ? null
                        : Border.all(color: T.border, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          !isOlda && prevSame ? 6 : 18),
                      topRight: Radius.circular(
                          isOlda && prevSame ? 6 : 18),
                      bottomLeft: Radius.circular(
                          !isOlda && nextSame ? 6 : 18),
                      bottomRight: Radius.circular(
                          isOlda && nextSame ? 6 : 18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 9),
                  child: Text(
                    msg.text,
                    style: AppType.ui(
                      size: 14.5,
                      color: isOlda ? Colors.white : T.text,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                  ),
                ),
                if (!nextSame)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
                    child: Text(
                      fmtTime(msg.at),
                      style: AppType.mono(size: 10.5, color: T.text3),
                    ),
                  ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
