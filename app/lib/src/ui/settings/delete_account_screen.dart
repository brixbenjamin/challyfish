import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';

/// Erasure, with typed intent.
///
/// A yes/no dialog is the wrong control for the only irreversible action in the
/// product: there is no undo, no grace period, and no soft-delete window.
/// Typing the word is a deliberate half-second of friction in the one place
/// friction is correct.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    required this.isLinked,
    required this.onConfirmDelete,
    required this.onCancel,
    required this.onDeleted,
    super.key,
  });

  final bool isLinked;

  /// Returns true when the server confirmed the deletion. Nothing local is
  /// wiped on false.
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onCancel;
  final VoidCallback onDeleted;

  static const inputKey = Key('delete-input'); // niche:allow widget key
  static const confirmKey = Key('delete-confirm'); // niche:allow widget key
  static const cancelKey = Key('delete-cancel'); // niche:allow widget key
  static const errorKey = Key('delete-error'); // niche:allow widget key

  static const confirmWord =
      'DELETE'; // niche:allow — typed control token, compared not read

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _input = TextEditingController();
  bool _busy = false;
  String? _error;

  bool get _armed => _input.text.trim() == DeleteAccountScreen.confirmWord;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.onConfirmDelete();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onDeleted();
    } else {
      // Stay put and wipe nothing. A local wipe after a failed server call
      // would leave the user believing they deleted something they had not.
      // `context` is legal here: this is a State method, and `mounted` was
      // checked two lines up.
      setState(() => _error = context.l10n.deleteFailedNotice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onCancel),
        title: Text(l10n.deleteAccountTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(l10n.deleteHeadline, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(l10n.deleteScopeNotice),
            const SizedBox(height: 12),
            Text(l10n.deletePurchasesNotice),
            if (!widget.isLinked) ...[
              const SizedBox(height: 12),
              Text(l10n.deleteAnonymousNotice),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.deleteConfirmInstruction(DeleteAccountScreen.confirmWord),
            ),
            const SizedBox(height: 8),
            TextField(
              key: DeleteAccountScreen.inputKey,
              controller: _input,
              autocorrect: false,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                key: DeleteAccountScreen.errorKey,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              key: DeleteAccountScreen.cancelKey,
              onPressed: widget.onCancel,
              child: Text(l10n.keepMyAccountButton),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: DeleteAccountScreen.confirmKey,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: (_armed && !_busy) ? _delete : null,
              child: Text(l10n.deleteEverythingButton),
            ),
          ],
        ),
      ),
    );
  }
}
