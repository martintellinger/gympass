import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/store/store.dart' show kOwnerId;
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';

/// Member Thread — one conversation from the logged-in member's side.
/// [peerId] is the sentinel `kOwnerId` ('olda') for the owner conversation,
/// otherwise another member's id (member↔member chat).
class MemberThreadScreen extends ConsumerStatefulWidget {
  final String peerId;
  const MemberThreadScreen({super.key, required this.peerId});

  @override
  ConsumerState<MemberThreadScreen> createState() => _MemberThreadScreenState();
}

class _MemberThreadScreenState extends ConsumerState<MemberThreadScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastLen = -1;

  bool get _isOwner => widget.peerId == kOwnerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(gymRepositoryProvider).memberMarkRead(
            ref.read(currentMemberIdProvider),
            widget.peerId,
          );
      if (mounted) {
        ref.invalidate(conversationProvider(widget.peerId));
        ref.invalidate(memberInboxProvider);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    await ref.read(gymRepositoryProvider).memberSend(
          ref.read(currentMemberIdProvider),
          widget.peerId,
          t,
        );
    if (!mounted) return;
    ref.invalidate(conversationProvider(widget.peerId));
    ref.invalidate(memberInboxProvider);
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
    final l = L.of(context);
    final nav = navCb(context);

    final convoAsync = ref.watch(conversationProvider(widget.peerId));
    if (convoAsync.isLoading && !convoAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 5),
        ),
      );
    }
    if (convoAsync.hasError && !convoAsync.hasValue) {
      return ScreenFrame(
        child: LoadError(
          onRetry: () =>
              ref.invalidate(conversationProvider(widget.peerId)),
        ),
      );
    }

    Member? peer;
    if (!_isOwner) {
      for (final m in ref.watch(membersProvider).value ?? const <Member>[]) {
        if (m.id == widget.peerId) {
          peer = m;
          break;
        }
      }
    }
    final peerName = _isOwner ? l.mthrOwnerName : (peer?.name ?? '—');
    final peerSub = _isOwner
        ? l.mthrOwnerRole
        : (peer != null ? '${peer.tariff} · ${l.mthrMemberRole}' : '');
    final firstName = peerName.split(' ').first;

    final msgs = convoAsync.value ??
        const <({bool mine, String text, DateTime at})>[];
    if (_lastLen != msgs.length) {
      _lastLen = msgs.length;
      _scrollToEnd();
    }

    final hasText = _ctrl.text.trim().isNotEmpty;

    // Group bubbles by day.
    final groups = <_DayGroup>[];
    final map = <String, _DayGroup>{};
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
                  child: Row(
                    children: [
                      _isOwner
                          ? Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: T.accentSoft,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const AppIcon('shield',
                                  size: 18, color: T.accent),
                            )
                          : Avatar(name: peerName, size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              peerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppType.ui(
                                size: 14.5,
                                weight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              peerSub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppType.ui(size: 11.5, color: T.text2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: groups.isEmpty
                ? Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      _isOwner
                          ? l.mthrEmptyOwner
                          : l.mthrEmptyPeer(firstName),
                      textAlign: TextAlign.center,
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

          // Composer
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
                      onSubmitted: (_) => _send(),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      cursorColor: T.accent,
                      style:
                          AppType.ui(size: 14.5, color: T.text, height: 1.4),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 6),
                        border: InputBorder.none,
                        hintText: l.mthrComposerHint(firstName),
                        hintStyle: AppType.ui(
                            size: 14.5, color: T.text3, height: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: hasText ? _send : null,
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
  final List<({bool mine, String text, DateTime at})> items = [];
  _DayGroup(this.date);
}

class _Bubble extends StatelessWidget {
  final ({bool mine, String text, DateTime at}) msg;
  final ({bool mine, String text, DateTime at})? prev;
  final ({bool mine, String text, DateTime at})? next;
  const _Bubble({required this.msg, this.prev, this.next});

  @override
  Widget build(BuildContext context) {
    final mine = msg.mine;
    final prevSame = prev != null && prev!.mine == mine;
    final nextSame = next != null && next!.mine == mine;
    final top = prevSame ? 4.0 : 18.0;

    return Padding(
      padding: EdgeInsets.only(top: top - 6),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Column(
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mine ? T.accent : T.surface,
                      border:
                          mine ? null : Border.all(color: T.border, width: 1),
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(!mine && prevSame ? 6 : 18),
                        topRight:
                            Radius.circular(mine && prevSame ? 6 : 18),
                        bottomLeft:
                            Radius.circular(!mine && nextSame ? 6 : 18),
                        bottomRight:
                            Radius.circular(mine && nextSame ? 6 : 18),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 9),
                    child: Text(
                      msg.text,
                      style: AppType.ui(
                        size: 14.5,
                        color: mine ? Colors.white : T.text,
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
