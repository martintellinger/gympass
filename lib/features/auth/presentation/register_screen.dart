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

/// 02 — Roster-gated registration (brief §4.1 + /goal):
/// Step 1: name → must match an unclaimed club roster row.
/// Step 2: contact + password → claims the row, status `pending` until Olda
/// confirms (key / deposit). Tariff & student verification are the owner's
/// at approval, not collected here.
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

  int _step = 1;
  bool _gdpr = false;
  bool _busy = false;
  String? _error;
  bool _confirmEmailSent = false;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validEmail(String s) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

  Future<void> _checkRoster() async {
    final l = L.of(context);
    final first = _first.text.trim();
    final last = _last.text.trim();
    if (first.isEmpty || last.isEmpty) {
      setState(() => _error = l.authErrFields);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok =
          await ref.read(authNotifierProvider).rosterMatch(first, last);
      if (!mounted) return;
      setState(() {
        if (ok) {
          _step = 2;
        } else {
          _error = l.authErrNotInRoster;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = l.authErrGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l = L.of(context);
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final pass = _password.text;

    if (email.isEmpty || pass.isEmpty) {
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
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            phone: phone,
          );
      if (!hasSession && mounted) {
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

    if (_step == 1) {
      return AuthScaffold(
        title: l.authRegisterTitle,
        subtitle: l.authNameStepSubtitle,
        children: [
          AuthError(_error),
          AuthField(
            label: l.authFirstName,
            controller: _first,
            capitalization: TextCapitalization.words,
            autofillHint: AutofillHints.givenName,
            enabled: !_busy,
          ),
          AuthField(
            label: l.authLastName,
            controller: _last,
            capitalization: TextCapitalization.words,
            autofillHint: AutofillHints.familyName,
            enabled: !_busy,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: _busy ? l.authBusy : l.authContinue,
            full: true,
            onTap: _busy ? null : _checkRoster,
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

    // Step 2 — contact + password.
    return AuthScaffold(
      title: l.authRegisterTitle,
      subtitle: l.authContactStepSubtitle,
      children: [
        AuthError(_error),
        AuthField(
          label: l.authEmailLogin,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHint: AutofillHints.email,
          enabled: !_busy,
        ),
        AuthField(
          label: l.authPhoneOptional,
          controller: _phone,
          keyboardType: TextInputType.phone,
          autofillHint: AutofillHints.telephoneNumber,
          enabled: !_busy,
        ),
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
          lead: l.actionBack,
          linkLabel: l.authRegisterTitle,
          onTap: _busy
              ? () {}
              : () => setState(() {
                    _step = 1;
                    _error = null;
                  }),
        ),
      ],
    );
  }
}
