/// Async data providers over [GymRepository] — the screen-facing read layer.
///
/// Screens move off the synchronous mock `storeProvider` to these
/// `AsyncValue` providers one at a time. After a mutation, `ref.invalidate`
/// the relevant provider to refetch. `autoDispose` keeps a screen's data
/// from going stale across navigations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../store/models.dart';
import '../store/store.dart' show kCurrentMemberId;
import 'gym_repository_provider.dart';

/// The signed-in member's id. Real auth → the claimed `members` row
/// (`AppProfile.memberId`); mock/preview → the `kCurrentMemberId` sentinel
/// the in-memory store uses.
final currentMemberIdProvider = Provider<String>((ref) {
  if (authNotifier.backendEnabled) {
    return authNotifier.snapshot.profile?.memberId ?? kCurrentMemberId;
  }
  return kCurrentMemberId;
});

/// The signed-in member's full record.
final currentMemberProvider = FutureProvider.autoDispose<Member?>((ref) {
  final id = ref.watch(currentMemberIdProvider);
  return ref.watch(gymRepositoryProvider).memberById(id);
});

/// Current member's unified inbox (owner conversation + peer threads).
final memberInboxProvider =
    FutureProvider.autoDispose<List<MemberConvo>>((ref) {
  final id = ref.watch(currentMemberIdProvider);
  return ref.watch(gymRepositoryProvider).memberInbox(id);
});

/// A conversation the current member has with [peerId] (`kOwnerId` for the
/// owner thread).
final conversationProvider = FutureProvider.autoDispose
    .family<List<({bool mine, String text, DateTime at})>, String>(
  (ref, peerId) {
    final id = ref.watch(currentMemberIdProvider);
    return ref.watch(gymRepositoryProvider).conversation(id, peerId);
  },
);

/// Owner inbox — every member↔owner thread, newest first (admin messages).
final adminThreadsProvider =
    FutureProvider.autoDispose<List<ThreadSummary>>(
  (ref) => ref.watch(gymRepositoryProvider).adminThreads(),
);

/// Owner↔member thread messages (admin thread screen).
final ownerThreadProvider =
    FutureProvider.autoDispose.family<List<Message>, String>(
  (ref, memberId) =>
      ref.watch(gymRepositoryProvider).ownerThread(memberId),
);

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
