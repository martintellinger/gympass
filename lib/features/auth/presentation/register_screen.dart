import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../application/auth_notifier.dart';
import 'widgets.dart';

/// 02 — Registration form (brief §4.1 / §screens 2). Creates the auth user;
/// a DB trigger turns the metadata into a `pending` member row.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  String _tariff = 'standard';
  bool _gdpr = false;
  bool _busy = false;
  String? _error;
  bool _confirmEmailSent = false;

  Uint8List? _proofBytes;
  String? _proofName;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickProof() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final f = res?.files.firstOrNull;
    if (f != null && f.bytes != null) {
      setState(() {
        _proofBytes = f.bytes;
        _proofName = f.name;
      });
    }
  }

  bool _validEmail(String s) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

  Future<void> _submit() async {
    final l = L.of(context);
    final first = _first.text.trim();
    final last = _last.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final pass = _password.text;

    if (first.isEmpty ||
        last.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        pass.isEmpty) {
      setState(() => _error = l.authErrFields);
      return;
    }
    if (!_validEmail(email)) {
      setState(() => _error = l.authErrEmail);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = l.authErrPassword);
      return;
    }
    if (_tariff == 'student' && _proofBytes == null) {
      setState(() => _error = l.authErrStudentProof);
      return;
    }
    if (!_gdpr) {
      setState(() => _error = l.authErrGdpr);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final hasSession = await ref.read(authNotifierProvider).signUp(
            email: email,
            password: pass,
            firstName: first,
            lastName: last,
            phone: phone,
            tariffType: _tariff,
            studentProofBytes: _proofBytes,
            studentProofName: _proofName,
          );
      if (!hasSession && mounted) {
        // Project requires e-mail confirmation — no session yet.
        setState(() => _confirmEmailSent = true);
      }
      // With a session, the router redirect moves to the waiting screen.
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l.authErrGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    if (_confirmEmailSent) {
      return AuthScaffold(
        title: l.authConfirmEmailTitle,
        subtitle: l.authConfirmEmailBody,
        children: [
          const SizedBox(height: 8),
          AppButton(
            label: l.authLoginLink,
            full: true,
            onTap: () => context.go('/login'),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l.authRegisterTitle,
      subtitle: l.authRegisterSubtitle,
      children: [
        AuthError(_error),
        Row(
          children: [
            Expanded(
              child: AuthField(
                label: l.authFirstName,
                controller: _first,
                capitalization: TextCapitalization.words,
                autofillHint: AutofillHints.givenName,
                enabled: !_busy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthField(
                label: l.authLastName,
                controller: _last,
                capitalization: TextCapitalization.words,
                autofillHint: AutofillHints.familyName,
                enabled: !_busy,
              ),
            ),
          ],
        ),
        AuthField(
          label: l.authEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHint: AutofillHints.email,
          enabled: !_busy,
        ),
        AuthField(
          label: l.authPhone,
          controller: _phone,
          keyboardType: TextInputType.phone,
          autofillHint: AutofillHints.telephoneNumber,
          enabled: !_busy,
        ),
        Text(l.authTariff,
            style: AppType.ui(
                size: 13, weight: FontWeight.w500, color: T.text2)),
        const SizedBox(height: 6),
        Row(
          children: [
            _TariffChip(
              label: l.authTariffStandard,
              selected: _tariff == 'standard',
              onTap: _busy ? null : () => setState(() => _tariff = 'standard'),
            ),
            const SizedBox(width: 10),
            _TariffChip(
              label: l.authTariffStudent,
              selected: _tariff == 'student',
              onTap: _busy ? null : () => setState(() => _tariff = 'student'),
            ),
          ],
        ),
        if (_tariff == 'student') ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _busy ? null : _pickProof,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: Space.md, vertical: 14),
              decoration: BoxDecoration(
                color: T.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(
                    color: _proofBytes != null ? T.ok : T.border),
              ),
              child: Row(
                children: [
                  AppIcon(_proofBytes != null ? 'check' : 'plus',
                      size: 18,
                      color: _proofBytes != null ? T.ok : T.text2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _proofBytes != null
                          ? l.authStudentProofPicked
                          : '${l.authStudentProof} · ${l.authStudentProofPick}',
                      style: AppType.ui(
                          size: 14,
                          color: _proofBytes != null ? T.text : T.text2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        AuthField(
          label: l.authPassword,
          controller: _password,
          obscure: true,
          autofillHint: AutofillHints.newPassword,
          enabled: !_busy,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _busy ? null : () => setState(() => _gdpr = !_gdpr),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: _gdpr ? T.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.xs),
                    border: Border.all(
                        color: _gdpr ? T.accent : T.border, width: 1.5),
                  ),
                  child: _gdpr
                      ? const AppIcon('check', size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.authGdpr,
                      style: AppType.ui(size: 13.5, color: T.text2)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppButton(
          label: _busy ? l.authBusy : l.authCreateAccount,
          full: true,
          onTap: _busy ? null : _submit,
        ),
        const SizedBox(height: 4),
        AuthLinkRow(
          lead: l.authHaveAccount,
          linkLabel: l.authLoginLink,
          onTap: _busy ? () {} : () => context.go('/login'),
        ),
      ],
    );
  }
}

class _TariffChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _TariffChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? T.accentSoft : T.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: selected ? T.accent : T.border),
          ),
          child: Text(
            label,
            style: AppType.ui(
              size: 14,
              weight: FontWeight.w600,
              color: selected ? T.accent : T.text,
            ),
          ),
        ),
      ),
    );
  }
}
