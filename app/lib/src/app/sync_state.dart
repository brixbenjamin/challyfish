import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sync_status.dart';
import 'providers.dart';

/// The scheduler's status, as something the UI can watch.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncSchedulerProvider).statusStream;
});

/// Notices accumulate until the user acknowledges them, so one is never lost to
/// a rebuild between the sync finishing and the frame being drawn.
///
/// Riverpod 3's Notifier rather than the legacy StateNotifier: the subscription
/// belongs to the provider's own lifetime, which is what ref.onDispose gives.
class SyncNoticeNotifier extends Notifier<List<SyncNotice>> {
  @override
  List<SyncNotice> build() {
    final sub = ref
        .watch(syncSchedulerProvider)
        .noticeStream
        .listen((notice) => state = [...state, notice]);
    ref.onDispose(sub.cancel);
    return const [];
  }

  void dismiss(SyncNoticeKind kind) =>
      state = state.where((n) => n.kind != kind).toList();
}

final syncNoticeProvider =
    NotifierProvider<SyncNoticeNotifier, List<SyncNotice>>(
      SyncNoticeNotifier.new,
    );
