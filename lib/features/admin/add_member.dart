import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/screen_frame.dart';

/// Add Member 18 — manual add/edit member form for the owner.
/// Port of AddMember.jsx; when [editMemberId] is set the form prefills the
/// existing member and saves changes instead of creating a new member.
class AddMemberScreen extends ConsumerStatefulWidget {
  final String? editMemberId;
  const AddMemberScreen({super.key, this.editMemberId});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _tariff = 'Standard';
  int _length = 3;
  bool _hasKey = true;
  bool _isic = false;
  bool _customOn = false;
  int _price = 750;
  bool _submitted = false;

  bool get _isEdit =>
      widget.editMemberId != null && widget.editMemberId!.isNotEmpty;

  int get _tariffDefault => _tariff == 'Student' ? 500 : 750;
  int get _monthly => _customOn ? _price : _tariffDefault;
  int get _total => _monthly * _length;
  bool get _isCustomActive => _customOn && _monthly != _tariffDefault;

  bool get _ok {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text;
    final phone = _phoneCtrl.text;
    return name.length >= 2 &&
        (email.contains('@') || phone.length >= 9) &&
        _monthly > 0;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final existing = ref.read(storeProvider).memberById(widget.editMemberId!);
      if (existing != null) {
        _nameCtrl.text = existing.name;
        _emailCtrl.text = existing.email == '—' ? '' : existing.email;
        _phoneCtrl.text = existing.phone == '—' ? '' : existing.phone;
        _tariff = existing.tariff == 'Student' ? 'Student' : 'Standard';
        _isic = existing.isic;
        _hasKey = existing.hasKey;
        final defaultPrice = _tariff == 'Student' ? 500 : 750;
        final price = existing.monthlyPrice ?? defaultPrice;
        _customOn = price != defaultPrice;
        _price = price;
      }
    }
    _priceCtrl.text = _price.toString();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // Mirrors the JSX effect: when tariff changes & custom is off, follow default.
  void _syncTariffPrice() {
    if (!_customOn) {
      _price = _tariff == 'Student' ? 500 : 750;
      _priceCtrl.text = _price.toString();
    }
  }

  void _setPrice(int v) {
    final clamped = v < 0 ? 0 : v;
    setState(() {
      _price = clamped;
      _priceCtrl.value = TextEditingValue(
        text: clamped.toString(),
        selection: TextSelection.collapsed(offset: clamped.toString().length),
      );
    });
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_ok) return;
    final store = ref.read(storeProvider);
    final nav = navCb(context);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (_isEdit) {
      store.updateMember(
        widget.editMemberId!,
        (mm) => mm.copyWith(
          name: name,
          email: email.isEmpty ? '—' : email,
          phone: phone.isEmpty ? '—' : phone,
          tariff: _tariff,
          isic: _tariff == 'Student' && _isic,
          hasKey: _hasKey,
          monthlyPrice: _monthly,
        ),
      );
      nav('back', toast: L.of(context).addmMemberSavedToast(name));
      return;
    }

    final created = store.addMember(Member(
      id: '',
      name: name,
      email: email.isEmpty ? '—' : email,
      phone: phone.isEmpty ? '—' : phone,
      state: 'ok',
      tariff: _tariff,
      isic: _tariff == 'Student' && _isic,
      hasKey: _hasKey,
      monthlyPrice: _monthly,
      daysNum: _length * 30,
      joined: '5 · 2026',
      expiresAt: '~ ${_length * 30} dní',
    ));
    nav('list',
        toast: L.of(context).addmMemberAddedToast(created.name, _length));
  }

  void _cancel() => navCb(context)(_isEdit ? 'back' : 'list');

  String _csNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final nameTrim = _nameCtrl.text.trim();
    final nameInvalid = _submitted && nameTrim.length < 2;

    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => navCb(context)(_isEdit ? 'back' : 'list'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: T.surface,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: T.border),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon('back', size: 18, color: T.text),
                  ),
                ),
                Text(
                  _isEdit
                      ? L.of(context).addmTitleEdit
                      : L.of(context).addmTitle,
                  style: AppType.ui(
                    size: 14,
                    weight: FontWeight.w600,
                    color: T.text2,
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identity row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.xxs, vertical: 6),
                    child: Row(
                      children: [
                        Avatar(
                            name: nameTrim.isEmpty
                                ? L.of(context).addmTitle
                                : nameTrim,
                            size: 56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameTrim.isEmpty
                                    ? L.of(context).addmNoName
                                    : nameTrim,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.ui(
                                  size: 22,
                                  weight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  color: nameTrim.isEmpty
                                      ? T.text3
                                      : T.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _subtitle(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Základní
                  _FormSection(
                    label: L.of(context).addmSectionBasic,
                    children: [
                      _Field(
                        label: L.of(context).addmFieldName,
                        controller: _nameCtrl,
                        placeholder: L.of(context).addmFieldNamePlaceholder,
                        invalid: nameInvalid,
                        hint: nameInvalid
                            ? L.of(context).addmFieldNameError
                            : null,
                      ),
                      _Field(
                        label: L.of(context).addmFieldEmail,
                        controller: _emailCtrl,
                        placeholder: 'pavel.novak@email.cz',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _Field(
                        label: L.of(context).addmFieldPhone,
                        controller: _phoneCtrl,
                        placeholder: '+420 728 451 209',
                        mono: true,
                        keyboardType: TextInputType.phone,
                        last: true,
                      ),
                      if (_submitted &&
                          !_ok &&
                          nameTrim.length >= 2 &&
                          _monthly > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          child: Text(
                            L.of(context).addmContactRequired,
                            style: AppType.ui(size: 12, color: T.error),
                          ),
                        ),
                    ],
                  ),

                  // Tarif
                  _FormSection(
                    label: L.of(context).addmSectionTariff,
                    children: [
                      _RowSegment<String>(
                        value: _tariff,
                        onChange: (v) => setState(() {
                          _tariff = v;
                          _syncTariffPrice();
                        }),
                        options: [
                          _SegOpt('Standard', L.of(context).addmTariffStandard,
                              L.of(context).addmTariffStandardSub),
                          _SegOpt('Student', L.of(context).addmTariffStudent,
                              L.of(context).addmTariffStudentSub),
                        ],
                      ),
                      if (_tariff == 'Student')
                        _Toggle(
                          label: L.of(context).addmHasIsic,
                          value: _isic,
                          onChange: (v) => setState(() => _isic = v),
                          sub: L.of(context).addmHasIsicSub,
                        ),
                      if (!_isEdit)
                        _RowSegment<int>(
                          label: L.of(context).addmLength,
                          value: _length,
                          onChange: (v) => setState(() => _length = v),
                          options: [
                            _SegOpt(3, L.of(context).addmMonths(3), null),
                            _SegOpt(6, L.of(context).addmMonths(6), null),
                            _SegOpt(12, L.of(context).addmMonths(12), null),
                          ],
                        ),
                    ],
                  ),

                  // Cena za měsíc
                  _FormSection(
                    label: L.of(context).addmSectionPrice,
                    children: [
                      _Toggle(
                        label: L.of(context).addmCustomPrice,
                        value: _customOn,
                        onChange: (v) => setState(() {
                          _customOn = v;
                          _syncTariffPrice();
                        }),
                        sub: _customOn
                            ? L.of(context).addmCustomPriceOnSub(_tariffDefault)
                            : L
                                .of(context)
                                .addmCustomPriceOffSub(_tariffDefault),
                      ),
                      if (_customOn) _priceField(),
                      if (!_isEdit) _kCalcRow(),
                    ],
                  ),

                  // Klíč & kauce
                  _FormSection(
                    label: L.of(context).addmSectionKey,
                    children: [
                      _Toggle(
                        label: L.of(context).addmIssueKey,
                        value: _hasKey,
                        onChange: (v) => setState(() => _hasKey = v),
                        sub: L.of(context).addmIssueKeySub,
                      ),
                    ],
                  ),

                  // Submit
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _ok ? _submit : _submit,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: _ok ? T.accent : T.surface2,
                        borderRadius: BorderRadius.circular(Radii.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(_isEdit ? 'check' : 'user_plus',
                              size: 18,
                              color: _ok ? Colors.white : T.text3),
                          const SizedBox(width: 8),
                          Text(
                            _isEdit
                                ? L.of(context).addmSubmitEdit
                                : L.of(context).addmSubmit,
                            style: AppType.ui(
                              size: 16,
                              weight: FontWeight.w600,
                              color: _ok ? Colors.white : T.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _cancel,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: T.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        L.of(context).addmCancel,
                        style: AppType.ui(
                          size: 14,
                          weight: FontWeight.w500,
                          color: T.text2,
                        ),
                      ),
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

  Widget _subtitle() {
    final spans = <InlineSpan>[
      TextSpan(
        text: _tariff +
            (_tariff == 'Student' && _isic
                ? L.of(context).addmSubtitleIsic
                : ''),
      ),
    ];
    if (_isCustomActive) {
      spans.add(TextSpan(
        text: L.of(context).addmSubtitleCustomPrice,
        style: AppType.ui(size: 13, color: T.accent),
      ));
    }
    return RichText(
      text: TextSpan(
        style: AppType.ui(size: 13, color: T.text2),
        children: spans,
      ),
    );
  }

  Widget _priceField() {
    final invalid = _submitted && _monthly <= 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L.of(context).addmCustomPriceLabel,
            style: AppType.ui(
                size: 11, weight: FontWeight.w500, color: T.text2,
                letterSpacing: 0.2),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) {
                          final n = int.tryParse(v) ?? 0;
                          setState(() => _price = n);
                        },
                        cursorColor: T.accent,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        style: AppType.mono(
                          size: 22,
                          weight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: invalid ? T.error : T.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(L.of(context).addmPerMonth,
                        style: AppType.ui(size: 13, color: T.text2)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _step('−', () => _setPrice(_price - 50)),
              const SizedBox(width: 4),
              _step('+', () => _setPrice(_price + 50)),
            ],
          ),
          if (invalid)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(L.of(context).addmPriceError,
                  style: AppType.ui(size: 11.5, color: T.error)),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [400, 500, 600, 750, 900, 1200].map((p) {
              final sel = _price == p;
              return GestureDetector(
                onTap: () => _setPrice(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Space.s10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel ? T.accent : T.surface2,
                    borderRadius: BorderRadius.circular(Radii.pill),
                    border: Border.all(
                        color: sel ? Colors.transparent : T.border),
                  ),
                  child: Text(L.of(context).addmCzk(p),
                      style: AppType.mono(
                        size: 12,
                        weight: FontWeight.w500,
                        color: sel ? Colors.white : T.text2,
                      )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _step(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: T.surface2,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: T.border),
        ),
        alignment: Alignment.center,
        child: Text(icon,
            style: AppType.mono(
                size: 18, weight: FontWeight.w600, color: T.text)),
      ),
    );
  }

  Widget _kCalcRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                style: AppType.ui(size: 13, color: T.text2),
                children: [
                  TextSpan(text: L.of(context).addmToPay),
                  TextSpan(
                    text: '· $_monthly × $_length',
                    style: AppType.mono(size: 13, color: T.text3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: AppType.mono(
                size: 18,
                weight: FontWeight.w700,
                letterSpacing: -0.4,
                color: _isCustomActive ? T.accent : T.text,
              ),
              children: [
                TextSpan(text: _csNum(_total)),
                TextSpan(
                    text: ' ${L.of(context).addmCzkUnit}',
                    style: AppType.ui(size: 12, color: T.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _FormSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    // Strip trailing divider on the last child by clipping the container.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Text(
            label.toUpperCase(),
            style: AppType.ui(
              size: 11.5,
              weight: FontWeight.w600,
              letterSpacing: 0.4,
              color: T.text2,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg),
          child: Container(
            decoration: BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: T.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool mono;
  final bool last;
  final bool invalid;
  final String? hint;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.mono = false,
    this.last = false,
    this.invalid = false,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = (mono
        ? AppType.mono(
            size: 15.5,
            weight: FontWeight.w500,
            letterSpacing: -0.2,
            color: invalid ? T.error : T.text,
          )
        : AppType.ui(
            size: 15.5,
            weight: FontWeight.w500,
            letterSpacing: -0.2,
            color: invalid ? T.error : T.text,
          ));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: T.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppType.ui(
              size: 11,
              weight: FontWeight.w500,
              letterSpacing: 0.2,
              color: T.text2,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: T.accent,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: (mono
                  ? AppType.mono(
                      size: 15.5, weight: FontWeight.w500, color: T.text3)
                  : AppType.ui(
                      size: 15.5,
                      weight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: T.text3)),
            ),
            style: textStyle,
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(hint!,
                  style: AppType.ui(size: 11.5, color: T.error)),
            ),
        ],
      ),
    );
  }
}

class _SegOpt<V> {
  final V value;
  final String label;
  final String? sub;
  const _SegOpt(this.value, this.label, this.sub);
}

class _RowSegment<TVal> extends StatelessWidget {
  final String? label;
  final TVal value;
  final ValueChanged<TVal> onChange;
  final List<_SegOpt<TVal>> options;

  const _RowSegment({
    this.label,
    required this.value,
    required this.onChange,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppType.ui(
                size: 11,
                weight: FontWeight.w500,
                letterSpacing: 0.2,
                color: T.text2,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(Space.xs),
            decoration: BoxDecoration(
              color: T.surface2,
              borderRadius: BorderRadius.circular(Radii.s10),
            ),
            child: Row(
              children: [
                for (var i = 0; i < options.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 3,
                          right: i == options.length - 1 ? 0 : 3),
                      child: _seg(options[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(_SegOpt<TVal> o) {
    final active = o.value == value;
    return GestureDetector(
      onTap: () => onChange(o.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s6, vertical: 8),
        decoration: BoxDecoration(
          color: active ? T.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
              color: active ? T.border : Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              o.label,
              textAlign: TextAlign.center,
              style: AppType.ui(
                size: 13,
                weight: FontWeight.w600,
                letterSpacing: -0.2,
                color: active ? T.text : T.text2,
              ),
            ),
            if (o.sub != null) ...[
              const SizedBox(height: 2),
              Text(
                o.sub!,
                textAlign: TextAlign.center,
                style: AppType.mono(size: 10.5, color: T.text3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChange;
  final String? sub;

  const _Toggle({
    required this.label,
    required this.value,
    required this.onChange,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChange(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.ui(
                      size: 14.5,
                      weight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub!,
                        style: AppType.ui(size: 12, color: T.text2)),
                  ],
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
