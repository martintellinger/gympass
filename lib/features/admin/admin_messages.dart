import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';

/// Admin Messages 15 — 1:1 thread inbox (owner Olda <-> members).
/// Port of docs/design/gympass/project/screens/AdminMessages.jsx.
class AdminMessagesScreen extends ConsumerStatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  ConsumerState<AdminMessagesScreen> createState() =>
      _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends ConsumerState<AdminMessagesScreen> {
  final TextEditingController _qCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);
    final repo = ref.read(gymRepositoryProvider);
    final threadsAsync = ref.watch(adminThreadsProvider);

    if (threadsAsync.isLoading && !threadsAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 7),
        ),
      );
    }
    if (threadsAsync.hasError && !threadsAsync.hasValue) {
      return ScreenFrame(
        child: LoadError(
            onRetry: () => ref.invalidate(adminThreadsProvider)),
      );
    }

    final threads = threadsAsync.value ?? const <ThreadSummary>[];
    final filtered = _q.isEmpty
        ? threads
        : threads
            .where((t) =>
                t.member.name.toLowerCase().contains(_q.toLowerCase()))
            .toList();

    final allMembers =
        ref.watch(membersProvider).value ?? const <Member>[];
    final totalUnread = threads.fold<int>(0, (s, t) => s + t.unread);
    final unreadThreads = threads.where((t) => t.unread > 0).length;

    return ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
              // ── Header block ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L.of(context).amsgTitle,
                                style: AppType.ui(
                                  size: 28,
                                  weight: FontWeight.w700,
                                  color: T.text,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _subtitle(totalUnread, unreadThreads),
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openCompose(allMembers, nav),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: T.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const AppIcon('edit',
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // ── Search ──
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: T.surface,
                        border: Border.all(color: T.border),
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Row(
                        children: [
                          const AppIcon('search', size: 16, color: T.text2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _qCtrl,
                              onChanged: (v) => setState(() => _q = v),
                              cursorColor: T.accent,
                              style: AppType.ui(size: 14, color: T.text),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: L.of(context).amsgSearchHint,
                                hintStyle:
                                    AppType.ui(size: 14, color: T.text2),
                              ),
                            ),
                          ),
                          if (_q.isNotEmpty)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _qCtrl.clear();
                                setState(() => _q = '');
                              },
                              child: const AppIcon('x',
                                  size: 14, color: T.text3),
                            ),
                        ],
                      ),
                    ),
                    // ── Quick bulk actions ──
                    if (_q.isEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickPill(
                              icon: 'megaphone',
                              label: L.of(context).amsgBulkAll,
                              onTap: () => _openBroadcast(allMembers, repo, nav),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _QuickPill(
                              icon: 'alert',
                              label: L.of(context).amsgRemindDebtors,
                              onTap: () async {
                                final msg =
                                    L.of(context).amsgPaymentReminderMsg;
                                final sentToast =
                                    L.of(context).amsgRemindersSent;
                                final debtors = allMembers
                                    .where((m) => m.state == 'error');
                                for (final m in debtors) {
                                  await repo.sendOwnerMessage(m.id, msg,
                                      from: 'olda');
                                }
                                ref.invalidate(adminThreadsProvider);
                                nav('messages', toast: sentToast);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── List section ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                      child: Text(
                        L
                            .of(context)
                            .amsgThreadCount(filtered.length)
                            .toUpperCase(),
                        style: AppType.ui(
                          size: 11.5,
                          weight: FontWeight.w600,
                          color: T.text2,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 40, 12, 40),
                        child: Center(
                          child: Text(
                            _q.isNotEmpty
                                ? L.of(context).amsgEmptySearch(_q)
                                : L.of(context).amsgEmpty,
                            style: AppType.ui(size: 13, color: T.text3),
                          ),
                        ),
                      )
                    else
                      ...filtered.map((t) => _ThreadRow(
                            thread: t,
                            onTap: () async {
                              await repo.markOwnerThreadRead(t.member.id);
                              ref.invalidate(adminThreadsProvider);
                              nav('thread', arg: t.member.id);
                            },
                          )),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _subtitle(int totalUnread, int unreadThreads) {
    if (totalUnread <= 0) {
      return Text(
        L.of(context).amsgAllDone,
        style: AppType.ui(size: 13, color: T.text2),
      );
    }
    return Text.rich(
      TextSpan(
        style: AppType.ui(size: 13, color: T.text2),
        children: [
          TextSpan(
            text: L.of(context).amsgUnreadCount(totalUnread),
            style: AppType.ui(size: 13, color: T.text),
          ),
          TextSpan(
              text: ' · ${L.of(context).amsgUnreadThreads(unreadThreads)}'),
        ],
      ),
    );
  }

  void _openCompose(List<Member> members, NavCb nav) {
    showModalBottomSheet<void>(
      context: context,
      // Above the shell — keep the floating bottom-nav bar from overlapping.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _ComposeSheet(
        members: members,
        onPick: (id) {
          // Sheet is on the root navigator (useRootNavigator) — pop that.
          Navigator.of(context, rootNavigator: true).pop();
          nav('thread', arg: id);
        },
      ),
    );
  }

  void _openBroadcast(List<Member> members, GymRepository repo, NavCb nav) {
    showModalBottomSheet<void>(
      context: context,
      // Above the shell — keep the floating bottom-nav bar from overlapping.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _BroadcastSheet(
        members: members,
        repo: repo,
        onSent: (count) {
          // Sheet is on the root navigator (useRootNavigator) — pop that.
          Navigator.of(context, rootNavigator: true).pop();
          nav('messages', toast: L.of(context).amsgSentToMembers(count));
        },
      ),
    );
  }
}

// ─── Quick pill ───────────────────────────────────────────────────────────
class _QuickPill extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 6),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 16, color: T.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppType.ui(
                  size: 13,
                  weight: FontWeight.w500,
                  color: T.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Thread row ───────────────────────────────────────────────────────────
class _ThreadRow extends StatelessWidget {
  final ThreadSummary thread;
  final VoidCallback onTap;

  const _ThreadRow({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final member = thread.member;
    final last = thread.last;
    final unread = thread.unread;
    final at = last.at;
    final time = fmtRelDay(at) == 'dnes' ? fmtTime(at) : fmtRelDay(at);
    final isFromOlda = last.from == 'olda';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + unread badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(name: member.name, size: 44),
                if (unread > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: T.accent,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: T.bg, width: 2),
                      ),
                      child: Text(
                        '$unread',
                        style: AppType.mono(
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(
                            size: 15,
                            weight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: T.text,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: AppType.mono(
                          size: 11,
                          weight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: unread > 0 ? T.accent : T.text3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isFromOlda) ...[
                        Text(
                          L.of(context).amsgFromMePrefix,
                          style: AppType.mono(
                            size: 10.5,
                            weight: FontWeight.w600,
                            color: T.text3,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          last.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(
                            size: 13,
                            weight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: unread > 0 ? T.text : T.text2,
                            height: 1.35,
                          ),
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
    );
  }
}

// ─── Compose sheet ────────────────────────────────────────────────────────
class _ComposeSheet extends StatefulWidget {
  final List<Member> members;
  final ValueChanged<String> onPick;

  const _ComposeSheet({required this.members, required this.onPick});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _q.isEmpty
        ? widget.members
        : widget.members
            .where((m) => m.name.toLowerCase().contains(_q.toLowerCase()))
            .toList();

    final maxH = MediaQuery.of(context).size.height * 0.72;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(
          color: T.surface,
          border: Border(
            top: BorderSide(color: T.border),
            left: BorderSide(color: T.border),
            right: BorderSide(color: T.border),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(Space.s14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: T.divider)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        L.of(context).amsgComposeTitle,
                        style: AppType.ui(
                          size: 17,
                          weight: FontWeight.w700,
                          color: T.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: const AppIcon('x', size: 20, color: T.text2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: T.surface2,
                      border: Border.all(color: T.border),
                      borderRadius: BorderRadius.circular(Radii.s10),
                    ),
                    child: Row(
                      children: [
                        const AppIcon('search', size: 15, color: T.text2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (v) => setState(() => _q = v),
                            cursorColor: T.accent,
                            style: AppType.ui(size: 14, color: T.text),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: L.of(context).amsgComposeSearchHint,
                              hintStyle:
                                  AppType.ui(size: 14, color: T.text2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // List
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(Space.s6),
                shrinkWrap: true,
                children: filtered
                    .map((m) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onPick(m.id),
                          child: Padding(
                            padding: const EdgeInsets.all(Space.s10),
                            child: Row(
                              children: [
                                Avatar(name: m.name, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppType.ui(
                                          size: 14.5,
                                          weight: FontWeight.w600,
                                          color: T.text,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${m.tariff} · ${m.expiresAt}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppType.ui(
                                          size: 12,
                                          color: T.text2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Broadcast sheet ──────────────────────────────────────────────────────
class _BroadcastSheet extends StatefulWidget {
  final List<Member> members;
  final GymRepository repo;
  final ValueChanged<int> onSent;

  const _BroadcastSheet({
    required this.members,
    required this.repo,
    required this.onSent,
  });

  @override
  State<_BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends State<_BroadcastSheet> {
  final TextEditingController _textCtrl = TextEditingController();
  String _target = 'all';

  static const _templates = [
    'Zítra máme zavřeno do 14:00, revize elektroinstalace.',
    'Multipress je dočasně mimo provoz, náhradní díl dorazil.',
    'Pamatujte na klid v Klubu po 21:00, je tu někdo, kdo by spál.',
  ];

  // target key -> (label, filter)
  static final Map<String, ({String label, bool Function(Member) filter})>
      _targets = {
    'all': (label: 'Všem', filter: (m) => true),
    'overdue': (label: 'Dlužníkům', filter: (m) => m.state == 'error'),
    'warn': (label: 'Končícím', filter: (m) => m.state == 'warn'),
    'active': (label: 'Aktivním', filter: (m) => m.state == 'ok'),
  };

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  List<Member> get _recipients =>
      widget.members.where(_targets[_target]!.filter).toList();

  Future<void> _send() async {
    final t = _textCtrl.text.trim();
    final recipients = _recipients;
    if (t.isEmpty || recipients.isEmpty) return;
    for (final m in recipients) {
      await widget.repo.sendOwnerMessage(m.id, t, from: 'olda');
    }
    widget.onSent(recipients.length);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textCtrl.text.trim().isNotEmpty;
    final recipients = _recipients;
    final canSend = hasText && recipients.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Space.lg),
          decoration: const BoxDecoration(
            color: T.surface,
            border: Border(
              top: BorderSide(color: T.border),
              left: BorderSide(color: T.border),
              right: BorderSide(color: T.border),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L.of(context).amsgBroadcastTitle,
                          style: AppType.ui(
                            size: 17,
                            weight: FontWeight.w700,
                            color: T.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          L.of(context).amsgBroadcastSubtitle,
                          style: AppType.ui(size: 12, color: T.text2),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const AppIcon('x', size: 20, color: T.text2),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Komu
              Text(
                L.of(context).amsgBroadcastTo,
                style: AppType.ui(
                  size: 11,
                  weight: FontWeight.w600,
                  color: T.text2,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(Space.xs),
                decoration: BoxDecoration(
                  color: T.surface2,
                  borderRadius: BorderRadius.circular(Radii.s10),
                ),
                child: Row(
                  children: _targets.entries.map((e) {
                    final k = e.key;
                    final active = _target == k;
                    final count =
                        widget.members.where(e.value.filter).length;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _target = k),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Space.xs, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? T.bg : Colors.transparent,
                            borderRadius: BorderRadius.circular(Radii.sm),
                            border: Border.all(
                              color:
                                  active ? T.border : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                e.value.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: AppType.ui(
                                  size: 12.5,
                                  weight: FontWeight.w600,
                                  color: active ? T.text : T.text2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$count',
                                style: AppType.mono(
                                  size: 10.5,
                                  color: T.text3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              // Textarea
              Container(
                decoration: BoxDecoration(
                  color: T.surface2,
                  border: Border.all(color: T.border),
                  borderRadius: BorderRadius.circular(Radii.s10),
                ),
                padding: const EdgeInsets.all(Space.md),
                child: TextField(
                  controller: _textCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 4,
                  minLines: 4,
                  cursorColor: T.accent,
                  style: AppType.ui(size: 14.5, color: T.text, height: 1.4),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: L.of(context).amsgBroadcastTextHint,
                    hintStyle: AppType.ui(size: 14.5, color: T.text2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Templates
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _templates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final tpl = _templates[i];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _textCtrl.text = tpl;
                        setState(() {});
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 240),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: T.surface2,
                          border: Border.all(color: T.border),
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Text(
                          tpl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(size: 11.5, color: T.text2),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              // Send button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canSend ? _send : null,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: canSend ? T.accent : T.surface2,
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon('send',
                          size: 16,
                          color: canSend ? Colors.white : T.text3),
                      const SizedBox(width: 8),
                      Text(
                        L.of(context).amsgSendButton(recipients.length),
                        style: AppType.ui(
                          size: 15,
                          weight: FontWeight.w600,
                          color: canSend ? Colors.white : T.text3,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
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
