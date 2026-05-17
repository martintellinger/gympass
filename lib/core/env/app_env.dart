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

  /// Default project for the BýtFit Klub club app. The **publishable** key
  /// (`sb_publishable_…`) is designed by Supabase to ship in public client
  /// bundles — it grants no privileges by itself; Row-Level Security (see
  /// `docs/backend/rls.sql`) is the real boundary. A separate prod project
  /// can still be supplied per-build via `--dart-define`, which overrides
  /// these defaults.
  static const _defaultUrl = 'https://yktounljghdypfhbdxws.supabase.co';
  static const _defaultAnonKey = 'sb_publishable_5b_9c8vsPbwXuLD9mu3-CA_WpD_mqMH';

  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: _defaultUrl);

  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: _defaultAnonKey);

  /// True once both Supabase values are present. When false the app must
  /// keep running on the in-memory mock (current behaviour) — wiring the
  /// backend is gated on this so the web preview never breaks if the
  /// secrets aren't supplied to a build.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
