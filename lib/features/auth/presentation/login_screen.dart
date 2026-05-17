import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../application/auth_notifier.dart';
import 'widgets.dart';

/// 01 — Login (e-mail + password) + link to registration (brief §screens 1).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = L.of(context);
    final email = _email.text.trim();
    final pass = _password.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = l.authErrFields);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authNotifierProvider).signIn(email, pass);
      // Navigation is driven by the router redirect (refreshListenable).
    } on AuthException catch (e) {
      final invalid = e.statusCode == '400' ||
          e.message.toLowerCase().contains('invalid');
      setState(() => _error = invalid ? l.authErrInvalid : e.message);
    } catch (_) {
      setState(() => _error = l.authErrGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.authLoginTitle,
      subtitle: l.authLoginSubtitle,
      children: [
        AuthError(_error),
        AuthField(
          label: l.authEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHint: AutofillHints.email,
          enabled: !_busy,
        ),
        AuthField(
          label: l.authPassword,
          controller: _password,
          obscure: true,
          autofillHint: AutofillHints.password,
          enabled: !_busy,
        ),
        const SizedBox(height: 8),
        AppButton(
          label: _busy ? l.authBusy : l.authSignIn,
          full: true,
          onTap: _busy ? null : _submit,
        ),
        const SizedBox(height: 4),
        AuthLinkRow(
          lead: l.authNoAccount,
          linkLabel: l.authRegisterLink,
          onTap: _busy ? () {} : () => context.go('/register'),
        ),
      ],
    );
  }
}
