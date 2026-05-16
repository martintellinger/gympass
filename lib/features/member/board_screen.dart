import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/screen_frame.dart';

const Color _eventColor = T.event;

class _PostType {
  final String label;
  final Color color;
  final String icon;
  const _PostType(this.label, this.color, this.icon);
}

const Map<String, _PostType> _postTypes = {
  'pinned': _PostType('Připnuto', T.accent, 'pin'),
  'outage': _PostType('Mimo provoz', T.error, 'tool'),
  'warning': _PostType('Pozor', T.warn, 'alert'),
  'promo': _PostType('Akce', T.ok, 'tag'),
  'event': _PostType('Událost', _eventColor, 'calendar'),
  'fixed': _PostType('Opraveno', T.ok, 'check'),
  'info': _PostType('Info', T.text2, 'megaphone'),
};

String _postTypeLabel(BuildContext context, String type) {
  final l = L.of(context);
  switch (type) {
    case 'pinned':
      return l.boardTypePinned;
    case 'outage':
      return l.boardTypeOutage;
    case 'warning':
      return l.boardTypeWarning;
    case 'promo':
      return l.boardTypePromo;
    case 'event':
      return l.boardTypeEvent;
    case 'fixed':
      return l.boardTypeFixed;
    case 'info':
    default:
      return l.boardTypeInfo;
  }
}

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
  final int id;
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

const List<_Post> _posts = [
  _Post(
    id: 1,
    type: 'pinned',
    pinned: true,
    title: 'Zítra zavřeno do 14:00',
    body:
        'Revize elektroinstalace. Otevíráme po obědě, omlouvám se za komplikace. Pokud potřebuješ vyzvednout věci ze skříňky dřív, napiš mi.',
    date: '15. 5. · 16:30',
    author: 'Olda',
  ),
  _Post(
    id: 2,
    type: 'outage',
    title: 'Bench press č. 2 — mimo provoz',
    body:
        'Prasklo lano. Náhradní díl objednaný, dorazí příští týden. Bench č. 1 a multipress fungují normálně.',
    date: '14. 5. · 09:12',
    author: 'Olda',
  ),
  _Post(
    id: 3,
    type: 'promo',
    title: 'Doporuč kamaráda, dostaneš měsíc zdarma',
    body:
        'Pošli někomu, kdo by sem zapadl. Když si zaplatí první 3 měsíce, automaticky se ti přidá +30 dní ke členství. Stačí, aby v žádosti napsal tvoje jméno.',
    date: '12. 5. · 11:00',
    author: 'Olda',
    cta: 'Sdílet pozvánku',
  ),
  _Post(
    id: 4,
    type: 'event',
    title: 'Společné běhání · pondělky 18:00',
    body:
        'Od příštího týdne zkoušíme pravidelný okruh kolem Stromovky. Tempo lehké, 5–8 km. Sraz vždy v 18:00 u vchodu. Bez přihlášky, kdo přijde, ten běží.',
    date: '10. 5. · 19:45',
    author: 'Pavel N.',
  ),
  _Post(
    id: 5,
    type: 'fixed',
    title: 'Sprcha č. 3 opravena',
    body: 'Sifon vyčištěn, voda zase teče. Díky všem, kdo nahlásili.',
    date: '8. 5. · 14:20',
    author: 'Olda',
  ),
  _Post(
    id: 6,
    type: 'warning',
    title: 'Klíče — neházejte je za dveře',
    body:
        'Pár lidí mi nechalo klíč zaklepaný za vstupními dveřmi. Prosím nedělejte to — zámek se zasekává a kdokoli to vidí. Buď klíč nechte u sebe, nebo mi ho předejte osobně.',
    date: '5. 5. · 08:00',
    author: 'Olda',
  ),
];

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
  _Filter('event', 'Události', _eventColor),
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
    final filtered = _posts.where((p) {
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                        _BoardPost(post: filtered[i]),
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
          borderRadius: BorderRadius.circular(100),
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
  const _BoardPost({required this.post});

  @override
  Widget build(BuildContext context) {
    final meta = _postTypes[post.type] ?? _postTypes['info']!;
    final c = meta.color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(14),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                            Text(
                              _postTypeLabel(context, post.type)
                                  .toUpperCase(),
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
                      Text(
                        post.date,
                        style: AppType.mono(size: 11.5, color: T.text3),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Avatar(name: post.author, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            post.author,
                            style: AppType.ui(size: 12, color: T.text3),
                          ),
                        ],
                      ),
                      if (post.cta != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
