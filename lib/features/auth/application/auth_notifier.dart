import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env/app_env.dart';
import '../data/auth_repository.dart';
import '../domain/app_profile.dart';

enum AuthPhase { loading, signedOut, signedIn }

@immutable
class AuthSnapshot {
  final AuthPhase phase;
  final AppProfile? profile;

  const AuthSnapshot(this.phase, {this.profile});

  bool get isSignedIn => phase == AuthPhase.signedIn;
  bool get isLoading => phase == AuthPhase.loading;

  /// Signed in but the `members` row isn't readable yet — the trigger hasn't
  /// run, or the e-mail isn't confirmed. Treated like "pending" for routing.
  bool get awaitingProfile => isSignedIn && profile == null;
}

/// Bridges Supabase Auth → app state. Used both as a [GoRouter]
/// `refreshListenable` (so navigation reacts to sign-in/out) and via
/// [authNotifierProvider] inside screens.
///
/// When `AppEnv.hasSupabase` is false (no credentials in this build) it stays
/// permanently signed-out and the router falls back to the dev persona
/// picker, so the in-memory preview never breaks.
class AuthNotifier extends ChangeNotifier {
  AuthRepository? _repo;
  StreamSubscription<AuthState>? _sub;

  AuthSnapshot _snap = const AuthSnapshot(AuthPhase.loading);
  AuthSnapshot get snapshot => _snap;

  bool? _backendOverride;
  bool get backendEnabled => _backendOverride ?? AppEnv.hasSupabase;

  /// Test seam: keep the app on the in-memory mock (no auth gate), matching
  /// the documented "mock preview never breaks" contract. Widget tests that
  /// pump the whole app call this in `setUp`.
  @visibleForTesting
  void debugUseMock() {
    _backendOverride = false;
    _sub?.cancel();
    _set(const AuthSnapshot(AuthPhase.signedOut));
  }

  AuthRepository get _repository =>
      _repo ??= AuthRepository(Supabase.instance.client);

  /// Called once from `main()` after `Supabase.initialize`.
  void start() {
    if (!AppEnv.hasSupabase) {
      _set(const AuthSnapshot(AuthPhase.signedOut));
      return;
    }
    final repo = _repository;
    _resolve(repo.currentSession);
    _sub = repo.authStateChanges().listen((s) => _resolve(s.session));
  }

  Future<void> _resolve(Session? session) async {
    if (session == null) {
      _set(const AuthSnapshot(AuthPhase.signedOut));
      return;
    }
    try {
      final profile = await _repository.fetchProfile();
      _set(AuthSnapshot(AuthPhase.signedIn, profile: profile));
    } catch (_) {
      // Network/RLS hiccup — keep them signed in but profile-less so the
      // waiting screen (with a retry) is shown rather than a hard error.
      _set(const AuthSnapshot(AuthPhase.signedIn));
    }
  }

  void _set(AuthSnapshot s) {
    _snap = s;
    notifyListeners();
  }

  // ── Actions (UI calls these; routing reacts via notifyListeners) ────────

  Future<void> signIn(String email, String password) =>
      _repository.signIn(email: email, password: password);

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariffType,
    Uint8List? studentProofBytes,
    String? studentProofName,
  }) =>
      _repository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        tariffType: tariffType,
        studentProofBytes: studentProofBytes,
        studentProofName: studentProofName,
      );

  Future<void> signOut() => _repository.signOut();

  /// Re-fetch the profile (waiting screen "refresh" — picks up the owner's
  /// approval without a full sign-out).
  Future<void> refreshProfile() => _resolve(_repository.currentSession);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Single instance shared by the top-level router and the widget tree.
final authNotifier = AuthNotifier();

final authNotifierProvider =
    ChangeNotifierProvider<AuthNotifier>((ref) => authNotifier);
