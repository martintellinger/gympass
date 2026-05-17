import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env/app_env.dart';
import 'features/auth/application/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Supabase only when credentials are present. If they aren't
  // (e.g. an isolated test build), the app keeps running on the in-memory
  // mock so the web preview never breaks — see docs/backend/README.md.
  if (AppEnv.hasSupabase) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );
  }

  authNotifier.start();

  runApp(const ProviderScope(child: BytFitApp()));
}
