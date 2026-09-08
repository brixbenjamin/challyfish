import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/doctrine.dart';

/// The reading section.
///
/// Deliberately thin: no search, no bookmarks, no highlights, no reading
/// progress. Every one of those serves the Collector anti-persona and competes
/// with the daily action for attention. This exists to explain the actions and
/// must never be the reason someone opens the app.
class DoctrineListScreen extends StatelessWidget {
  const DoctrineListScreen({
    required this.groups,
    required this.entriesByGroup,
    required this.onOpen,
    super.key,
  });

  final List<DoctrineGroup> groups;
  final Map<String, List<DoctrineEntry>> entriesByGroup;
  final void Function(DoctrineEntry entry) onOpen;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.doctrineTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.l10n.doctrineEmpty),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.doctrineTitle)),
      body: ListView(
        children: [
          for (final group in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                group.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (group.blurb != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(group.blurb!),
              ),
            for (final entry
                in entriesByGroup[group.id] ?? const <DoctrineEntry>[])
              ListTile(title: Text(entry.title), onTap: () => onOpen(entry)),
          ],
        ],
      ),
    );
  }
}
