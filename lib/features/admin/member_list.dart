import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../l10n/app_localizations.dart';
import '../../core/store/models.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/status_pill.dart';

String _sortLabel(BuildContext context, String key) {
  switch (key) {
    case 'expiration':
      return L.of(context).mlistSortLabelExpiration;
    case 'name':
      return L.of(context).mlistSortLabelName;
    case 'tariff':
      return L.of(context).mlistSortLabelTariff;
    default:
      return '';
  }
}

/// Member List 11 — filterable/searchable/sortable member list for admin.
class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  final TextEditingController _qCtrl = TextEditingController();
  String _q = '';
  String _filter = 'all'; // all | ok | warn | error
  String _sortBy = 'expiration'; // expiration | name | tariff
  String _sortDir = 'asc';
  String _keyFilter = 'any'; // any | with | without
  String _tariffFilter = 'any'; // any | Standard | Student

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  // Czech-aware-ish localeCompare fallback.
  int _cmpCs(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  String _fmtDays(Member m) {
    if (m.suspended) return 'pozastaveno';
    if (m.daysNum < 0) {
      final n = m.daysNum.abs();
      return 'před $n ${n == 1 ? 'dnem' : 'dny'}';
    }
    if (m.daysNum == 1) return '1 den';
    if (m.daysNum < 5) return '${m.daysNum} dny';
    return '${m.daysNum} dní';
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: T.scrimSheet,
      isScrollControlled: true,
      builder: (_) => _FilterSortSheet(
        sortBy: _sortBy,
        sortDir: _sortDir,
        keyFilter: _keyFilter,
        tariffFilter: _tariffFilter,
        onPickSort: (v) => setState(() => _sortBy = v),
        onToggleDir: () => setState(
            () => _sortDir = _sortDir == 'asc' ? 'desc' : 'asc'),
        onPickKey: (v) => setState(() => _keyFilter = v),
        onPickTariff: (v) => setState(() => _tariffFilter = v),
        onReset: () => setState(() {
          _sortBy = 'expiration';
          _sortDir = 'asc';
          _keyFilter = 'any';
          _tariffFilter = 'any';
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final nav = navCb(context);

    final all = store.members;
    final counts = <String, int>{
      'all': all.length,
      'ok': all.where((m) => m.state == 'ok').length,
      'warn': all.where((m) => m.state == 'warn').length,
      'error': all.where((m) => m.state == 'error').length,
    };

    final filtered = all.where((m) {
      if (_filter != 'all' && m.state != _filter) return false;
      if (_keyFilter == 'with' && !m.hasKey) return false;
      if (_keyFilter == 'without' && m.hasKey) return false;
      if (_tariffFilter != 'any' && m.tariff != _tariffFilter) return false;
      if (_q.isNotEmpty) {
        final haystack =
            '${m.name} ${m.email} ${m.phone} ${m.tariff}'.toLowerCase();
        if (!haystack.contains(_q.toLowerCase())) return false;
      }
      return true;
    }).toList();

    final extraFiltersCount =
        (_keyFilter != 'any' ? 1 : 0) + (_tariffFilter != 'any' ? 1 : 0);

    final sorted = [...filtered]..sort((a, b) {
        var d = 0;
        if (_sortBy == 'name') d = _cmpCs(a.name, b.name);
        if (_sortBy == 'expiration') d = a.daysNum - b.daysNum;
        if (_sortBy == 'tariff') {
          d = _cmpCs(a.tariff, b.tariff);
          if (d == 0) d = a.daysNum - b.daysNum;
        }
        return _sortDir == 'asc' ? d : -d;
      });

    final memberWord = sorted.length == 1
        ? 'člen'
        : (sorted.length > 1 && sorted.length < 5 ? 'členové' : 'členů');

    return ScreenFrame(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
              // ── Header block ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L.of(context).mlistTitle,
                                style: AppType.ui(
                                  size: 28,
                                  weight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                L.of(context).mlistSubtitle(
                                  counts['all']!,
                                  counts['ok']!,
                                  counts['warn']! + counts['error']!,
                                ),
                                style: AppType.ui(
                                  size: 12.5,
                                  color: T.text2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _RoundBtn(
                              icon: 'sliders',
                              onTap: _openSortSheet,
                            ),
                            if (extraFiltersCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 16),
                                  height: 16,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: T.accent,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: T.bg, width: 2),
                                  ),
                                  child: Text(
                                    '$extraFiltersCount',
                                    style: AppType.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        _RoundBtn(
                          icon: 'user_plus',
                          primary: true,
                          onTap: () => nav('addMember'),
                        ),
                      ],
                    ),

                    // ── Search ──
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: T.surface,
                        border: Border.all(color: T.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                hintText: L.of(context).mlistSearchHint,
                                hintStyle:
                                    AppType.ui(size: 14, color: T.text3),
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
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child:
                                    AppIcon('x', size: 14, color: T.text3),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Filter chips ──
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            _Chip(
                              active: _filter == 'all',
                              onTap: () => setState(() => _filter = 'all'),
                              label: L.of(context).mlistChipAll(counts['all']!),
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              active: _filter == 'ok',
                              onTap: () => setState(() => _filter = 'ok'),
                              dot: StatusState.ok,
                              label: L.of(context).mlistChipActive(counts['ok']!),
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              active: _filter == 'warn',
                              onTap: () => setState(() => _filter = 'warn'),
                              dot: StatusState.warn,
                              label: L.of(context).mlistChipEnding(counts['warn']!),
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              active: _filter == 'error',
                              onTap: () =>
                                  setState(() => _filter = 'error'),
                              dot: StatusState.error,
                              label: L.of(context).mlistChipOverdue(counts['error']!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── List block ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section header (tap toggles dir)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() =>
                          _sortDir = _sortDir == 'asc' ? 'desc' : 'asc'),
                      child: Container(
                        color: T.bg,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: AppType.ui(
                                  size: 11.5,
                                  weight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: T.text2,
                                ),
                                children: [
                                  TextSpan(
                                      text:
                                          '${sorted.length} ${memberWord.toUpperCase()}'),
                                  TextSpan(
                                    text: ' · ',
                                    style:
                                        AppType.ui(color: T.text3, size: 11.5, weight: FontWeight.w600, letterSpacing: 0.4),
                                  ),
                                  TextSpan(
                                    text: _sortLabel(context, _sortBy)
                                        .toUpperCase(),
                                    style: AppType.ui(
                                      color: T.accent,
                                      size: 11.5,
                                      weight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _sortDir == 'asc' ? '↑' : '↓',
                              style: AppType.mono(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: T.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (sorted.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 12),
                        child: Text(
                          _q.isNotEmpty
                              ? L.of(context).mlistEmptySearch(_q)
                              : L.of(context).mlistEmptyFilter,
                          textAlign: TextAlign.center,
                          style: AppType.ui(size: 13, color: T.text3),
                        ),
                      )
                    else
                      ...sorted.map(
                        (m) => _MemberRow(
                          member: m,
                          daysLabel: _fmtDays(m),
                          onTap: () =>
                              nav('detail', arg: m.id),
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

class _RoundBtn extends StatelessWidget {
  final String icon;
  final bool primary;
  final VoidCallback onTap;
  const _RoundBtn(
      {required this.icon, this.primary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? T.accent : T.surface,
          shape: BoxShape.circle,
          border: primary ? null : Border.all(color: T.border),
        ),
        child: AppIcon(
          icon,
          size: 18,
          color: primary ? Colors.white : T.text,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final String label;
  final StatusState? dot;
  const _Chip({
    required this.active,
    required this.onTap,
    required this.label,
    this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
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
              StatusDot(state: dot!, size: 6),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppType.ui(
                size: 13,
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

class _MemberRow extends StatelessWidget {
  final Member member;
  final String daysLabel;
  final VoidCallback onTap;
  const _MemberRow({
    required this.member,
    required this.daysLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = member;
    final stateColor = m.state == 'ok'
        ? T.ok
        : m.state == 'warn'
            ? T.warn
            : m.state == 'error'
                ? T.error
                : T.text2;

    final String subLabel = m.state == 'ok'
        ? L.of(context).mlistRowUntilExpiry
        : m.state == 'warn'
            ? L.of(context).mlistRowEnding
            : m.state == 'error'
                ? L.of(context).mlistRowOverdue
                : L.of(context).mlistRow30Plus;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.divider)),
        ),
        child: Row(
          children: [
            Avatar(name: m.name, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          m.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(
                            size: 15,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (m.isic) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: T.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ISIC',
                            style: AppType.ui(
                              size: 9.5,
                              weight: FontWeight.w700,
                              color: T.text2,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        m.tariff,
                        style: AppType.ui(size: 12.5, color: T.text2),
                      ),
                      const SizedBox(width: 6),
                      Text('·',
                          style:
                              AppType.ui(size: 12.5, color: T.text3)),
                      const SizedBox(width: 6),
                      if (m.hasKey)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon('key',
                                size: 11,
                                color: m.overdue ? T.error : T.text2),
                            const SizedBox(width: 3),
                            Text(
                              L.of(context).mlistRowKey,
                              style: AppType.ui(
                                size: 12.5,
                                color: m.overdue ? T.error : T.text2,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          L.of(context).mlistRowNoKey,
                          style: AppType.ui(size: 12.5, color: T.text3),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  daysLabel,
                  style: AppType.mono(
                    size: 13,
                    weight: FontWeight.w600,
                    color: stateColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: AppType.ui(size: 11, color: T.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSortSheet extends StatelessWidget {
  final String sortBy;
  final String sortDir;
  final String keyFilter;
  final String tariffFilter;
  final ValueChanged<String> onPickSort;
  final VoidCallback onToggleDir;
  final ValueChanged<String> onPickKey;
  final ValueChanged<String> onPickTariff;
  final VoidCallback onReset;

  const _FilterSortSheet({
    required this.sortBy,
    required this.sortDir,
    required this.keyFilter,
    required this.tariffFilter,
    required this.onPickSort,
    required this.onToggleDir,
    required this.onPickKey,
    required this.onPickTariff,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        // Local mirror so the sheet re-renders immediately while also
        // propagating to the parent screen state.
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.fromBorderSide(BorderSide(color: T.border)),
            ),
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        L.of(context).mlistSheetTitle,
                        style: AppType.ui(
                          size: 17,
                          weight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              onReset();
                              setSheetState(() {});
                            },
                            child: Text(
                              L.of(context).mlistSheetReset,
                              style:
                                  AppType.ui(size: 12.5, color: T.text2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).pop(),
                            child: const AppIcon('x',
                                size: 20, color: T.text2),
                          ),
                        ],
                      ),
                    ],
                  ),

                  _SheetLabel(L.of(context).mlistSheetSortBy),
                  ...[
                    (
                      'expiration',
                      L.of(context).mlistSortOptExpirationTitle,
                      L.of(context).mlistSortOptExpirationDesc
                    ),
                    (
                      'name',
                      L.of(context).mlistSortOptNameTitle,
                      L.of(context).mlistSortOptNameDesc
                    ),
                    (
                      'tariff',
                      L.of(context).mlistSortOptTariffTitle,
                      L.of(context).mlistSortOptTariffDesc
                    ),
                  ].map((o) {
                    final active = o.$1 == sortBy;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        onPickSort(o.$1);
                        setSheetState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              active ? T.surface2 : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.$2,
                                    style: AppType.ui(
                                      size: 14,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    o.$3,
                                    style: AppType.ui(
                                      size: 11.5,
                                      color: T.text2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (active)
                              const AppIcon('check',
                                  size: 18,
                                  color: T.accent,
                                  stroke: 2.4),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      onToggleDir();
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: T.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            child: Text(
                              sortDir == 'asc' ? '↑' : '↓',
                              textAlign: TextAlign.center,
                              style: AppType.mono(
                                size: 18,
                                color: T.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sortDir == 'asc'
                                      ? L.of(context).mlistSheetAscending
                                      : L.of(context).mlistSheetDescending,
                                  style: AppType.ui(
                                    size: 14,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  L.of(context).mlistSheetTapToToggle,
                                  style: AppType.ui(
                                    size: 11.5,
                                    color: T.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _SheetLabel(L.of(context).mlistSheetTariff),
                  _Seg(
                    value: tariffFilter,
                    onChange: (v) {
                      onPickTariff(v);
                      setSheetState(() {});
                    },
                    options: [
                      ('any', L.of(context).mlistTariffOptBoth),
                      ('Standard', 'Standard'),
                      ('Student', 'Student'),
                    ],
                  ),

                  _SheetLabel(L.of(context).mlistSheetKey),
                  _Seg(
                    value: keyFilter,
                    onChange: (v) {
                      onPickKey(v);
                      setSheetState(() {});
                    },
                    options: [
                      ('any', L.of(context).mlistKeyOptAll),
                      ('with', L.of(context).mlistKeyOptWith),
                      ('without', L.of(context).mlistKeyOptWithout),
                    ],
                  ),

                  const SizedBox(height: 18),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: T.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        L.of(context).mlistSheetApply,
                        style: AppType.ui(
                          size: 15,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: AppType.ui(
          size: 11,
          weight: FontWeight.w600,
          letterSpacing: 0.4,
          color: T.text2,
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  final List<(String, String)> options;
  const _Seg({
    required this.value,
    required this.onChange,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: T.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChange(options[i].$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: options[i].$1 == value
                        ? T.bg
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: options[i].$1 == value
                          ? T.border
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    options[i].$2,
                    style: AppType.ui(
                      size: 13,
                      weight: FontWeight.w600,
                      color: options[i].$1 == value ? T.text : T.text2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
