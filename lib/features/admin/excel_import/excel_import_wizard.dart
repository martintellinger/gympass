import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/nav.dart';
import '../../../core/store/models.dart';
import '../../../core/store/store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/haptics.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/screen_frame.dart';
import '../../../shared/widgets/skeleton.dart';
import 'import_diff.dart';

/// Excel migration wizard (Phase 8) — UI on mock data.
///
/// The real `.xlsx` is not in the repo and parsing it needs an `excel` +
/// `file_picker` dependency wired to the file system; that lands with the
/// backend. Here the "Vybrat soubor" step synthesises a realistic sheet from
/// the current roster (so the diff is honest and a re-import is idempotent),
/// after a short simulated parse so the skeleton/loading path is exercised.
///
/// Product defaults baked in (documented in the handoff):
/// • match identity = e-mail (case-insensitive), fallback normalised name;
/// • protected fields (name / tariff / price) clashing ⇒ conflict, never
///   auto-applied — the owner resolves each one;
/// • non-protected changes (phone / key) are opt-in via a checkbox;
/// • unchanged rows are shown but never touched (Excel stays the control
///   layer, re-import safe).
class ExcelImportWizard extends ConsumerStatefulWidget {
  const ExcelImportWizard({super.key});

  @override
  ConsumerState<ExcelImportWizard> createState() => _ExcelImportWizardState();
}

enum _Step { pick, parsing, mapping, diff, done }

class _ExcelImportWizardState extends ConsumerState<ExcelImportWizard> {
  _Step _step = _Step.pick;
  List<ImportRow> _rows = const [];
  List<DiffEntry> _entries = const [];

  /// Per-row decisions keyed by list index.
  final Set<int> _includeAdded = {};
  final Set<int> _includeChanged = {};
  final Map<int, String> _conflictChoice = {}; // 'app' | 'excel' | 'skip'

  int _applied = 0;

  // ── Synthetic sheet ──────────────────────────────────────────────────────
  // Built from the live roster so the diff exercises every category and a
  // second run yields all-unchanged (idempotent).
  List<ImportRow> _syntheticSheet(List<Member> members) {
    final rows = <ImportRow>[];
    for (var i = 0; i < members.length && i < 8; i++) {
      final m = members[i];
      final price = m.monthlyPrice ?? (m.tariff == 'Student' ? 500 : 750);
      // Row 2: phone edited (non-protected → "changed").
      // Row 4: tariff edited (protected → "conflict").
      // Everything else: identical (→ "unchanged").
      rows.add(ImportRow(
        name: m.name,
        email: m.email,
        phone: i == 2 ? '+420 777 000 111' : m.phone,
        tariff: i == 4 ? (m.tariff == 'Student' ? 'Standard' : 'Student')
            : m.tariff,
        monthlyPrice: price,
        hasKey: i == 6 ? !m.hasKey : m.hasKey,
      ));
    }
    // Two members only in the spreadsheet (→ "added").
    rows.add(const ImportRow(
      name: 'Tomáš Příchozí',
      email: 'tomas.prichozi@email.cz',
      phone: '+420 608 220 145',
      tariff: 'Standard',
      monthlyPrice: 750,
      hasKey: false,
    ));
    rows.add(const ImportRow(
      name: 'Lucie Nová',
      email: 'lucie.nova@email.cz',
      phone: '+420 723 884 010',
      tariff: 'Student',
      monthlyPrice: 500,
      hasKey: true,
    ));
    return rows;
  }

  Future<void> _pickFile() async {
    setState(() => _step = _Step.parsing);
    // A 34-row sheet parses with a perceptible delay in production — exercise
    // the skeleton path rather than faking instant data.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final members = ref.read(storeProvider).members;
    final rows = _syntheticSheet(members);
    final entries = diffImport(rows, members);
    // Sensible defaults: bring in new people and safe field changes; leave
    // conflicts for an explicit decision.
    _includeAdded
      ..clear()
      ..addAll([
        for (var i = 0; i < entries.length; i++)
          if (entries[i].kind == DiffKind.added) i
      ]);
    _includeChanged
      ..clear()
      ..addAll([
        for (var i = 0; i < entries.length; i++)
          if (entries[i].kind == DiffKind.changed) i
      ]);
    _conflictChoice
      ..clear()
      ..addEntries([
        for (var i = 0; i < entries.length; i++)
          if (entries[i].kind == DiffKind.conflict) MapEntry(i, 'skip')
      ]);
    setState(() {
      _rows = rows;
      _entries = entries;
      _step = _Step.mapping;
    });
  }

  Member _merge(Member m, ImportRow r, {required bool takeExcel}) {
    if (!takeExcel) return m;
    return m.copyWith(
      name: r.name,
      email: r.email,
      phone: r.phone,
      tariff: r.tariff,
      monthlyPrice: r.monthlyPrice,
      hasKey: r.hasKey,
    );
  }

  Member _newMember(ImportRow r) => Member(
        id: 'imp_${r.email.hashCode.toUnsigned(20)}',
        name: r.name,
        phone: r.phone,
        email: r.email.isEmpty ? '—' : r.email,
        state: 'ok',
        daysNum: 30,
        tariff: r.tariff,
        hasKey: r.hasKey,
        isic: r.tariff == 'Student',
        joined: 'import 5 · 2026',
        expiresAt: '—',
        monthlyPrice: r.monthlyPrice,
      );

  void _apply() {
    final additions = <Member>[];
    final updates = <String, Member>{};
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      switch (e.kind) {
        case DiffKind.added:
          if (_includeAdded.contains(i)) additions.add(_newMember(e.row));
        case DiffKind.changed:
          if (_includeChanged.contains(i) && e.existing != null) {
            updates[e.existing!.id] =
                _merge(e.existing!, e.row, takeExcel: true);
          }
        case DiffKind.conflict:
          final choice = _conflictChoice[i] ?? 'skip';
          if (choice == 'excel' && e.existing != null) {
            updates[e.existing!.id] =
                _merge(e.existing!, e.row, takeExcel: true);
          }
        case DiffKind.unchanged:
          break;
      }
    }
    ref
        .read(storeProvider)
        .importMembers(additions: additions, updates: updates);
    Haptics.success();
    setState(() {
      _applied = additions.length + updates.length;
      _step = _Step.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(step: _step),
          Expanded(
            child: switch (_step) {
              _Step.pick => _PickStep(onPick: _pickFile),
              _Step.parsing => const _ParsingStep(),
              _Step.mapping => _MappingStep(
                  rowCount: _rows.length,
                  onContinue: () => setState(() => _step = _Step.diff),
                ),
              _Step.diff => _DiffStep(
                  entries: _entries,
                  includeAdded: _includeAdded,
                  includeChanged: _includeChanged,
                  conflictChoice: _conflictChoice,
                  onToggleAdded: (i) => setState(() => _includeAdded
                      .contains(i)
                      ? _includeAdded.remove(i)
                      : _includeAdded.add(i)),
                  onToggleChanged: (i) => setState(() => _includeChanged
                      .contains(i)
                      ? _includeChanged.remove(i)
                      : _includeChanged.add(i)),
                  onConflict: (i, v) =>
                      setState(() => _conflictChoice[i] = v),
                  onApply: _apply,
                ),
              _Step.done => _DoneStep(
                  count: _applied,
                  onDone: () => navCb(context)('adminMore',
                      toast: l.ximpDoneToast(_applied)),
                ),
            },
          ),
        ],
      ),
    );
  }
}

// ── Header with back + step trail ──────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final idx = switch (step) {
      _Step.pick => 0,
      _Step.parsing || _Step.mapping => 1,
      _Step.diff => 2,
      _Step.done => 3,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => navCb(context)('back'),
                icon: const AppIcon('back', size: 20, color: T.text),
              ),
              Expanded(
                child: Text(
                  l.ximpTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.ui(
                    size: 22,
                    weight: FontWeight.w700,
                    color: T.text,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  Container(
                    width: 22,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= idx ? T.accent : T.surface2,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                  if (i < 3) const SizedBox(width: 5),
                ],
                const SizedBox(width: 10),
                Text(
                  l.ximpStepOf(idx + 1, 4),
                  style: AppType.mono(size: 11, color: T.text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: pick ───────────────────────────────────────────────────────────
class _PickStep extends StatelessWidget {
  const _PickStep({required this.onPick});
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: T.accentSoft,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: const AppIcon('copy', size: 28, color: T.accent),
          ),
          const SizedBox(height: 16),
          Text(
            l.ximpPickTitle,
            textAlign: TextAlign.center,
            style: AppType.ui(
              size: 18,
              weight: FontWeight.w700,
              color: T.text,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.ximpPickBody,
            textAlign: TextAlign.center,
            style: AppType.ui(size: 13.5, color: T.text2, height: 1.5),
          ),
          const Spacer(),
          AppButton(
            label: l.ximpPickCta,
            full: true,
            icon: const AppIcon('download', size: 18),
            onTap: onPick,
          ),
          const SizedBox(height: 10),
          Text(
            l.ximpPickNote,
            textAlign: TextAlign.center,
            style: AppType.ui(size: 11.5, color: T.text3, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ── Step 1b: parsing (skeleton) ────────────────────────────────────────────
class _ParsingStep extends StatelessWidget {
  const _ParsingStep();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.ximpParsing,
            style: AppType.ui(size: 13.5, color: T.text2),
          ),
          const SizedBox(height: 16),
          const SkeletonList(rows: 6),
        ],
      ),
    );
  }
}

// ── Step 2: mapping preview ────────────────────────────────────────────────
class _MappingStep extends StatelessWidget {
  const _MappingStep({required this.rowCount, required this.onContinue});
  final int rowCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final maps = <(String, String)>[
      ('Jméno', l.ximpFieldName),
      ('E-mail', l.ximpFieldEmail),
      ('Telefon', l.ximpFieldPhone),
      ('Tarif', l.ximpFieldTariff),
      ('Cena/měs.', l.ximpFieldPrice),
      ('Klíč', l.ximpFieldKey),
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Text(
                l.ximpMappingTitle(rowCount),
                style: AppType.ui(
                  size: 15,
                  weight: FontWeight.w600,
                  color: T.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.ximpMappingBody,
                style: AppType.ui(size: 12.5, color: T.text2, height: 1.5),
              ),
              const SizedBox(height: 14),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: T.surface,
                  border: Border.all(color: T.border),
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < maps.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 16),
                          color: T.divider,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                maps[i].$1,
                                style: AppType.mono(
                                  size: 12.5,
                                  color: T.text2,
                                ),
                              ),
                            ),
                            const AppIcon('arrowRight',
                                size: 14, color: T.text3),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                maps[i].$2,
                                textAlign: TextAlign.right,
                                style: AppType.ui(
                                  size: 13.5,
                                  weight: FontWeight.w500,
                                  color: T.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: AppButton(
            label: l.ximpMappingCta,
            full: true,
            onTap: onContinue,
          ),
        ),
      ],
    );
  }
}

// ── Step 3: diff ───────────────────────────────────────────────────────────
class _DiffStep extends StatelessWidget {
  const _DiffStep({
    required this.entries,
    required this.includeAdded,
    required this.includeChanged,
    required this.conflictChoice,
    required this.onToggleAdded,
    required this.onToggleChanged,
    required this.onConflict,
    required this.onApply,
  });

  final List<DiffEntry> entries;
  final Set<int> includeAdded;
  final Set<int> includeChanged;
  final Map<int, String> conflictChoice;
  final ValueChanged<int> onToggleAdded;
  final ValueChanged<int> onToggleChanged;
  final void Function(int, String) onConflict;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final s = ImportSummary.of(entries);
    final willApply = includeAdded.length +
        includeChanged.length +
        conflictChoice.values.where((v) => v == 'excel').length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: l.ximpSumAdded(s.added), color: T.ok),
              _Tag(label: l.ximpSumChanged(s.changed), color: T.warn),
              _Tag(label: l.ximpSumConflict(s.conflicts), color: T.error),
              _Tag(label: l.ximpSumUnchanged(s.unchanged), color: T.text2),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: entries.length,
            itemBuilder: (_, i) => _DiffTile(
              entry: entries[i],
              index: i,
              includeAdded: includeAdded,
              includeChanged: includeChanged,
              conflictChoice: conflictChoice,
              onToggleAdded: onToggleAdded,
              onToggleChanged: onToggleChanged,
              onConflict: onConflict,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: AppButton(
            label: l.ximpApplyCta(willApply),
            full: true,
            onTap: willApply == 0 ? null : onApply,
          ),
        ),
      ],
    );
  }
}

class _DiffTile extends StatelessWidget {
  const _DiffTile({
    required this.entry,
    required this.index,
    required this.includeAdded,
    required this.includeChanged,
    required this.conflictChoice,
    required this.onToggleAdded,
    required this.onToggleChanged,
    required this.onConflict,
  });

  final DiffEntry entry;
  final int index;
  final Set<int> includeAdded;
  final Set<int> includeChanged;
  final Map<int, String> conflictChoice;
  final ValueChanged<int> onToggleAdded;
  final ValueChanged<int> onToggleChanged;
  final void Function(int, String) onConflict;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final (Color c, String label) = switch (entry.kind) {
      DiffKind.added => (T.ok, l.ximpKindAdded),
      DiffKind.changed => (T.warn, l.ximpKindChanged),
      DiffKind.conflict => (T.error, l.ximpKindConflict),
      DiffKind.unchanged => (T.text3, l.ximpKindUnchanged),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.row.name,
                  style: AppType.ui(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: entry.kind == DiffKind.unchanged
                        ? T.text2
                        : T.text,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  label,
                  style: AppType.ui(
                    size: 11,
                    weight: FontWeight.w600,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
          if (entry.changedFields.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l.ximpChangedFields(entry.changedFields.join(', ')),
              style: AppType.ui(size: 12, color: T.text2, height: 1.4),
            ),
          ],
          if (entry.kind == DiffKind.added) ...[
            const SizedBox(height: 8),
            _CheckRow(
              value: includeAdded.contains(index),
              label: l.ximpIncludeNew,
              onTap: () => onToggleAdded(index),
            ),
          ],
          if (entry.kind == DiffKind.changed) ...[
            const SizedBox(height: 8),
            _CheckRow(
              value: includeChanged.contains(index),
              label: l.ximpApplyChange,
              onTap: () => onToggleChanged(index),
            ),
          ],
          if (entry.kind == DiffKind.conflict) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _Seg(
                  label: l.ximpKeepApp,
                  active: (conflictChoice[index] ?? 'skip') == 'app',
                  onTap: () => onConflict(index, 'app'),
                ),
                const SizedBox(width: 6),
                _Seg(
                  label: l.ximpTakeExcel,
                  active: (conflictChoice[index] ?? 'skip') == 'excel',
                  onTap: () => onConflict(index, 'excel'),
                ),
                const SizedBox(width: 6),
                _Seg(
                  label: l.ximpSkip,
                  active: (conflictChoice[index] ?? 'skip') == 'skip',
                  onTap: () => onConflict(index, 'skip'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(
      {required this.value, required this.label, required this.onTap});
  final bool value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.selection();
        onTap();
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? T.accent : Colors.transparent,
              border: Border.all(color: value ? T.accent : T.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: value
                ? const AppIcon('check', size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppType.ui(size: 12.5, color: T.text2),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.selection();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? T.accentSoft : T.surface2,
            border: Border.all(color: active ? T.accent : T.border),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Text(
            label,
            style: AppType.ui(
              size: 11.5,
              weight: FontWeight.w600,
              color: active ? T.accent : T.text2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: AppType.ui(size: 12, weight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Step 4: done ───────────────────────────────────────────────────────────
class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.count, required this.onDone});
  final int count;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: T.okSoft,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: const AppIcon('check', size: 30, color: T.ok),
          ),
          const SizedBox(height: 16),
          Text(
            l.ximpDoneTitle,
            textAlign: TextAlign.center,
            style: AppType.ui(
              size: 18,
              weight: FontWeight.w700,
              color: T.text,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.ximpDoneBody(count),
            textAlign: TextAlign.center,
            style: AppType.ui(size: 13.5, color: T.text2, height: 1.5),
          ),
          const Spacer(),
          AppButton(label: l.ximpDoneCta, full: true, onTap: onDone),
        ],
      ),
    );
  }
}
