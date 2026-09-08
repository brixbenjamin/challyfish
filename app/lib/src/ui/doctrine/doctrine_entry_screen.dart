import 'package:flutter/material.dart';

import '../../domain/archetype.dart';
import '../../domain/doctrine.dart';

class DoctrineEntryScreen extends StatelessWidget {
  const DoctrineEntryScreen({
    required this.entry,
    this.relatedArchetype,
    super.key,
  });

  final DoctrineEntry entry;
  final Archetype? relatedArchetype;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: Theme.of(context).textTheme.headlineSmall),
            if (relatedArchetype != null) ...[
              const SizedBox(height: 8),
              Text(relatedArchetype!.name),
            ],
            const SizedBox(height: 16),
            // bodyMd is rendered as plain text for now. A markdown renderer is
            // a design-pass decision, not a foundations one, and plain text is
            // honest about that.
            Text(entry.bodyMd),
          ],
        ),
      ),
    );
  }
}
