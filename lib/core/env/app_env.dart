/// Build-time environment configuration.
///
/// Secrets are **never** hardcoded or committed. They are injected at build
/// time via `--dart-define` (or `--dart-define-from-file`), e.g.:
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
/// ```
///
/// The web build is a public static bundle (GitHub Pages), so only the
/// **anon** key may be shipped — never the service-role key. Real protection
/// is Row-Level Security in Postgres (see `docs/backend/rls.sql`), not key
/// secrecy. Use a separate Supabase project for the public demo vs. the
/// owner's real data.
library;

class AppEnv {
  const AppEnv._();

  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True once both Supabase values are present. When false the app must
  /// keep running on the in-memory mock (current behaviour) — wiring the
  /// backend is gated on this so the web preview never breaks if the
  /// secrets aren't supplied to a build.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
