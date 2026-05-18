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

import '../../features/auth/application/auth_notifier.dart';
import '../store/store.dart';
import 'gym_repository.dart';
import 'mock_gym_repository.dart';
import 'supabase_gym_repository.dart';

/// Real Supabase only when the backend is actually active. This mirrors the
/// auth seam (`authNotifier.backendEnabled`, which honours both
/// `AppEnv.hasSupabase` and the `debugUseMock` test/preview override) so
/// tests and the no-credentials preview keep running on the in-memory mock
/// instead of hitting an uninitialised Supabase client.
final gymRepositoryProvider = Provider<GymRepository>((ref) {
  if (authNotifier.backendEnabled) {
    return const SupabaseGymRepository();
  }
  return MockGymRepository(ref.watch(storeProvider));
});
