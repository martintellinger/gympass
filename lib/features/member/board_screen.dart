import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/board_post_style.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';

String _filterLabel(BuildContext context, String key) {
  final l = L.of(context);
  switch (key) {
    case 'all':
      return l.boardFilterAll;
    case 'outage':
      return l.boardFilterOutage;
    case 'warning':
      return l.boardFilterWarning;
    case 'promo':
      return l.boardFilterPromo;
    case 'event':
      return l.boardFilterEvent;
    default:
      return key;
  }
}

class _Post {
  final String id;
  final String type;
  final bool pinned;
  final String title;
  final String body;
  final String date;
  final String author;
  final String? cta;
  const _Post({
    required this.id,
    required this.type,
    this.pinned = false,
    required this.title,
    required this.body,
    required this.date,
    required this.author,
    this.cta,
  });
}


class _Filter {
  final String key;
  final String label;
  final Color? dot;
  const _Filter(this.key, this.label, this.dot);
}

const List<_Filter> _filters = [
  _Filter('all', 'Vše', null),
  _Filter('outage', 'Výpadky', T.error),
  _Filter('warning', 'Pozor', T.warn),
  _Filter('promo', 'Akce', T.ok),
  _Filter('event', 'Události', T.event),
];

/// Board 07 — nástěnka klubu (port of BoardScreen.jsx).
class BoardScreenView extends ConsumerStatefulWidget {
  const BoardScreenView({super.key});

  @override
  ConsumerState<BoardScreenView> createState() => _BoardScreenViewState();
}

class _BoardScreenViewState extends ConsumerState<BoardScreenView> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final isOwner =
        GoRouterState.of(context).matchedLocation == '/admin/board';
    final boardAsync = ref.watch(boardPostsProvider);
    if (boardAsync.isLoading && !boardAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 5),
        ),
      );
    }
    if (boardAsync.hasError && !boardAsync.hasValue) {
      return ScreenFrame(
        child:
            LoadError(onRetry: () => ref.invalidate(boardPostsProvider)),
      );
    }
    final posts = [
      for (final b in boardAsync.value ?? const <BoardPost>[])
        _Post(
          id: b.id,
          type: b.type,
          pinned: b.pinned,
          title: b.title,
          body: b.body,
          date: '${b.at.day}. ${b.at.month}. ${b.at.year}',
          author: b.author,
          cta: b.cta,
        ),
    ];
    final filtered = posts.where((p) {
      if (_filter == 'all') return true;
      if (_filter == 'pinned') return p.pinned;
      return p.type == _filter;
    }).toList();

    // pinned first (stable)
    filtered.sort((a, b) => (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0));

    return ScreenFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header block
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back affordance — only when this screen was *pushed*
                      // (owner opening the board from "Více"). As a member tab
                      // it's reached via `go`, so canPop is false and no
                      // button shows, matching the prototype.
                      if (context.canPop())
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => navCb(context)('back'),
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  top: 2, bottom: 10, right: 8),
                              child:
                                  AppIcon('back', size: 20, color: T.text),
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                L.of(context).boardTitle,
                                style: AppType.ui(
                                  size: 28,
                                  weight: FontWeight.w700,
                                  color: T.text,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                L.of(context).boardSubtitle,
                                style: AppType.ui(
                                  size: 13.5,
                                  color: T.text2,
                                ),
                              ),
                            ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: T.ok,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                L.of(context).boardStatusOpen,
                                style: AppType.ui(size: 12, color: T.text2),
                              ),
                              if (isOwner) ...[
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => navCb(context)('broadcast'),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: T.accent,
                                      borderRadius:
                                          BorderRadius.circular(Radii.md),
                                    ),
                                    child: const AppIcon('plus',
                                        size: 18, color: T.bg),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            for (var i = 0; i < _filters.length; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              _BChip(
                                label: _filterLabel(context, _filters[i].key),
                                dot: _filters[i].dot,
                                active: _filter == _filters[i].key,
                                onTap: () =>
                                    setState(() => _filter = _filters[i].key),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Posts list
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 12),
                          child: Text(
                            L.of(context).boardEmptyFilter,
                            textAlign: TextAlign.center,
                            style: AppType.ui(size: 13, color: T.text3),
                          ),
                        ),
                      for (var i = 0; i < filtered.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _BoardPost(
                          post: filtered[i],
                          onMenu: isOwner
                              ? () => _ownerMenu(filtered[i])
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _ownerMenu(_Post p) {
    final l = L.of(context);
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: T.scrimSheet,
      builder: (sheetCtx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(Radii.xl),
            border: Border.all(color: T.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetItem(
                icon: 'edit',
                label: l.boardOwnerEdit,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  navCb(context)('broadcast', arg: p.id);
                },
              ),
              const _SheetDivider(),
              _SheetItem(
                icon: 'pin',
                label: p.pinned ? l.boardOwnerUnpin : l.boardOwnerPin,
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await ref
                      .read(gymRepositoryProvider)
                      .setBoardPostPinned(p.id, !p.pinned);
                  ref.invalidate(boardPostsProvider);
                  if (!mounted) return;
                  showAppToast(
                      context,
                      p.pinned
                          ? l.boardUnpinnedToast
                          : l.boardPinnedToast);
                },
              ),
              const _SheetDivider(),
              _SheetItem(
                icon: 'trash',
                label: l.boardOwnerDelete,
                danger: true,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _confirmDeletePost(p);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePost(_Post p) {
    final l = L.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: T.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: const BorderSide(color: T.border),
        ),
        title: Text(
          l.boardDeleteTitle,
          style: AppType.ui(
              size: 17, weight: FontWeight.w700, color: T.text),
        ),
        content: Text(
          l.boardDeleteBody(p.title),
          style: AppType.ui(size: 14, color: T.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l.boardDeleteCancel,
              style: AppType.ui(
                  size: 14, weight: FontWeight.w600, color: T.text2),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(gymRepositoryProvider)
                  .deleteBoardPost(p.id);
              ref.invalidate(boardPostsProvider);
              if (!mounted) return;
              showAppToast(context, l.boardDeletedToast);
            },
            child: Text(
              l.boardDeleteConfirm,
              style: AppType.ui(
                  size: 14, weight: FontWeight.w600, color: T.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? T.error : T.text;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            AppIcon(icon, size: 18, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppType.ui(
                  size: 15, weight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: T.divider);
}

class _BChip extends StatelessWidget {
  final String label;
  final Color? dot;
  final bool active;
  final VoidCallback onTap;

  const _BChip({
    required this.label,
    required this.dot,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? T.text : T.surface,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: active ? T.text : T.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppType.ui(
                size: 12.5,
                weight: FontWeight.w500,
                color: active ? T.bg : T.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardPost extends StatelessWidget {
  final _Post post;
  final VoidCallback? onMenu;
  const _BoardPost({required this.post, this.onMenu});

  @override
  Widget build(BuildContext context) {
    final meta = boardPostStyle(post.type);
    final c = meta.color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Container(
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: post.pinned ? c : T.border),
        ),
        child: Stack(
          children: [
            // Left accent bar
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
                  // Type badge + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Space.sm, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.withAlpha(0x22),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(meta.icon,
                                  size: 11, color: c, stroke: 2.2),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  boardPostLabel(context, post.type)
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppType.ui(
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                    color: c,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.date,
                        style: AppType.mono(size: 11.5, color: T.text3),
                      ),
                      if (onMenu != null)
                        GestureDetector(
                          onTap: onMenu,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: AppIcon('more', size: 18, color: T.text3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.title,
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
                    post.body,
                    style: AppType.ui(
                      size: 13.5,
                      color: T.text2,
                      height: 1.5,
                    ),
                  ),
                  if (post.cta != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          post.cta!,
                          style: AppType.ui(
                            size: 12.5,
                            weight: FontWeight.w600,
                            color: c,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AppIcon('chevron', size: 13, color: c),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
