import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/sync_status.dart';

/// A non-modal strip above the dashboard content.
///
/// The user cannot fix a sync failure, so interrupting them with it would be
/// anxiety with no available action. This states the situation and gets out of
/// the way — it never covers today's action and never takes focus.
class SyncBanner extends StatelessWidget {
  const SyncBanner({
    required this.status,
    required this.notices,
    required this.onDismissNotice,
    super.key,
  });

  final SyncStatus status;
  final List<SyncNotice> notices;
  final void Function(SyncNoticeKind) onDismissNotice;

  static const messageKey = Key('sync-banner-message'); // niche:allow widget key
  static const dismissKey = Key('sync-banner-dismiss'); // niche:allow widget key

  /// Only two statuses have anything to say. `retrying` deliberately says
  /// nothing: one or two failed attempts is a blip, and reporting it would
  /// train the user to ignore this strip.
  String? _message(BuildContext context) => switch (status) {
    SyncStatus.offline => context.l10n.syncOfflineNotice,
    SyncStatus.failing => context.l10n.syncFailingNotice,
    SyncStatus.idle || SyncStatus.syncing || SyncStatus.retrying => null,
  };

  @override
  Widget build(BuildContext context) {
    final notice = notices.isEmpty ? null : notices.first;
    final message = _message(context);
    if (notice == null && message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                notice?.message ?? message!,
                key: messageKey,
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (notice != null)
              TextButton(
                key: dismissKey,
                onPressed: () => onDismissNotice(notice.kind),
                child: Text(context.l10n.dismissNoticeButton),
              ),
          ],
        ),
      ),
    );
  }
}
