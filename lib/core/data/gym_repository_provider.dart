/// Repository wiring point.
///
/// Chooses the implementation from the build environment: a real Supabase
/// build (secrets supplied via --dart-define) gets [SupabaseGymRepository],
/// everything else stays on the mock store. No screen depends on this yet —
/// it exists so that, when feature wiring (option B) begins, a screen swaps
/// `ref.watch(storeProvider)` for an `AsyncValue` provider over
/// `ref.watch(gymRepositoryProvider)` with nothing else to change.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_env.dart';
import '../store/store.dart';
import 'gym_repository.dart';
import 'mock_gym_repository.dart';
import 'supabase_gym_repository.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  if (AppEnv.hasSupabase) {
    return const SupabaseGymRepository();
  }
  return MockGymRepository(ref.watch(storeProvider));
});
