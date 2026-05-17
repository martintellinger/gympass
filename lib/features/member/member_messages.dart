import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/screen_frame.dart';

/// Member Messages — the logged-in member's inbox: the owner conversation
/// (always shown) plus every member↔member thread, newest first. The "+"
/// opens a compose sheet to start a chat with any other member.
class MemberMessagesScreen extends ConsumerWidget {
  const MemberMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final store = ref.watch(storeProvider);
    final nav = navCb(context);

    final convos = store.memberInbox(kCurrentMemberId);
    final unread = store.memberUnreadTotal(kCurrentMemberId);

    return ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.mmsgTitle,
                        style: AppType.ui(
                          size: 28,
                          weight: FontWeight.w700,
                          color: T.text,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unread > 0
                            ? l.mmsgUnreadCount(unread)
                            : l.mmsgAllRead,
                        style: AppType.ui(size: 13, color: T.text2),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openCompose(context, store, nav),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: T.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon('edit', size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in convos)
                  _ConvoRow(
                    convo: c,
                    name: c.isOwner
                        ? l.mthrOwnerName
                        : (store.memberById(c.peerId)?.name ?? '—'),
                    onTap: () {
                      store.memberMarkRead(kCurrentMemberId, c.peerId);
                      nav('mthread', arg: c.peerId);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCompose(BuildContext context, GymStore store, NavCb nav) {
    final others = store.members
        .where((m) => m.id != kCurrentMemberId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _ComposeSheet(
        members: others,
        onPick: (id) {
          Navigator.of(context).pop();
          nav('mthread', arg: id);
        },
      ),
    );
  }
}

class _ConvoRow extends StatelessWidget {
  final MemberConvo convo;
  final String name;
  final VoidCallback onTap;
  const _ConvoRow({
    required this.convo,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final unread = convo.unread;
    final time = fmtRelDay(convo.lastAt) == 'dnes'
        ? fmtTime(convo.lastAt)
        : fmtRelDay(convo.lastAt);

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
            Stack(
              clipBehavior: Clip.none,
              children: [
                convo.isOwner
                    ? Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: T.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon('shield',
                            size: 20, color: T.accent),
                      )
                    : Avatar(name: name, size: 44),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                convo.isOwner ? l.mthrOwnerName : name,
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
                            if (convo.isOwner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: T.accentSoft,
                                  borderRadius:
                                      BorderRadius.circular(Radii.sm),
                                ),
                                child: Text(
                                  l.mmsgOwnerTag,
                                  style: AppType.ui(
                                    size: 9.5,
                                    weight: FontWeight.w700,
                                    color: T.accent,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                      if (convo.lastMine) ...[
                        Text(
                          l.mmsgYouPrefix,
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
                          convo.lastText.isEmpty
                              ? l.mmsgNoMessagesYet
                              : convo.lastText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(
                            size: 13,
                            weight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: convo.lastText.isEmpty
                                ? T.text3
                                : (unread > 0 ? T.text : T.text2),
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
    final l = L.of(context);
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
                        l.mmsgComposeTitle,
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
                              hintText: l.mmsgComposeSearchHint,
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
                                        m.tariff,
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
