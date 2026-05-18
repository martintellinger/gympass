/// Async data providers over [GymRepository] — the screen-facing read layer.
///
/// Screens move off the synchronous mock `storeProvider` to these
/// `AsyncValue` providers one at a time. After a mutation, `ref.invalidate`
/// the relevant provider to refetch. `autoDispose` keeps a screen's data
/// from going stale across navigations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../store/models.dart';
import 'gym_repository_provider.dart';

/// All members (admin roster, dashboards).
final membersProvider = FutureProvider.autoDispose<List<Member>>(
  (ref) => ref.watch(gymRepositoryProvider).members(),
);

/// One member by id (detail screen).
final memberByIdProvider =
    FutureProvider.autoDispose.family<Member?, String>(
  (ref, id) => ref.watch(gymRepositoryProvider).memberById(id),
);

/// All payments (admin payments screen, history).
final paymentsProvider = FutureProvider.autoDispose<List<Payment>>(
  (ref) => ref.watch(gymRepositoryProvider).payments(),
);
