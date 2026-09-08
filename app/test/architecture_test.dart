import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// The domain and engine layers hold every rule that matters. They must stay
/// pure Dart so they can be tested exhaustively without a device, a database,
/// or a network. See docs/technical/architecture.md.
void main() {
  test('domain and engine import no framework or I/O packages', () {
    const banned = [
      'package:flutter/',
      'package:drift',
      'package:supabase',
      'dart:io',
    ];
    final offenders = <String>[];

    for (final dir in ['lib/src/domain', 'lib/src/engine']) {
      final root = Directory(dir);
      if (!root.existsSync()) continue;
      for (final file in root.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final source = file.readAsStringSync();
        for (final ban in banned) {
          if (source.contains("import '$ban")) {
            offenders.add('${file.path} imports $ban');
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  /// The brand tokens are a leaf. Everything may read them; they read nothing.
  /// The moment brand.dart imports a repository or a screen it stops being
  /// swappable, and answering Q1 stops being a one-file edit. See ADR-0021.
  test('the niche layer imports nothing from the app', () {
    final offenders = <String>[];
    final root = Directory('lib/src/niche');
    final crossLayer = RegExp(r"""import ['"](\.\./|package:feral/src/)""");

    if (root.existsSync()) {
      for (final file in root.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        if (crossLayer.hasMatch(file.readAsStringSync())) {
          offenders.add('${file.path} imports from lib/src/');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  /// The purchase SDK stays behind one interface. ADR-0017 picked RevenueCat
  /// with the explicit intent that the vendor stay replaceable, and that only
  /// holds while exactly one file knows the SDK exists. The moment a screen
  /// imports it to check something quickly, reversibility is gone and nobody
  /// notices until the vendor question comes back.
  test('only the gateway imports the purchases SDK', () {
    const allowed = 'lib/src/data/remote/revenuecat_gateway.dart';
    final offenders = <String>[];
    final root = Directory('lib');

    for (final file in root.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.path == allowed) continue;
      if (file.readAsStringSync().contains('package:purchases_flutter')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'purchases_flutter may only be imported by $allowed (ADR-0017).\n'
          'Go through PurchaseGateway instead:\n${offenders.join('\n')}',
    );
  });

  /// No screen supplies a user-facing word of its own. This is the rule that is
  /// cheap to hold from the first screen and expensive to retrofit across a
  /// finished app, which is the whole reason it is enforced on day one rather
  /// than agreed to. See ADR-0021 and ADR-0022.
  ///
  /// The rule is deliberately the blunt one — *no string literal at all* — rather
  /// than a clever match on `Text(...)`. A clever match misses the case that
  /// matters most: a paragraph wrapped across several lines with the opening
  /// quote on its own line, which is exactly the shape every long piece of body
  /// copy has.
  ///
  /// The blunt rule catches things that are not copy — a route name, a widget
  /// key, a `DateFormat` pattern. Those are exempted on their own line with
  /// `// niche:allow <reason>`, which makes each one a visible decision in a
  /// diff rather than an invisible one. If the exemptions ever outnumber the
  /// real strings, the rule is wrong and should be revisited — not silenced.
  test('no string literal in the UI layer', () {
    // Skips imports, comments, and anything explicitly exempted.
    final literal = RegExp(r"""(?<![\w$])['"]""");
    final offenders = <String>[];

    // `notifications/` is scanned for the same reason `ui/` is: the reminder's
    // title and body are read by a user, and they are the copy a context-bound
    // lookup could not have reached (plan 2 Task 15). A rule that stopped at the
    // widget tree would have missed the one string that proves the mechanism.
    for (final dir in ['lib/src/ui', 'lib/src/notifications']) {
      final root = Directory(dir);
      if (!root.existsSync()) continue;
      for (final file in root.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
            continue;
          }
          if (trimmed.startsWith('//')) continue;
          if (line.contains('// niche:allow')) continue;
          if (literal.hasMatch(line)) {
            offenders.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Move these into lib/l10n/app_en.arb, or mark the line\n'
          '`// niche:allow <reason>` if it is genuinely not user-facing:\n'
          '${offenders.join('\n')}',
    );
  });

  /// Every string has a description saying what it is for and where it appears,
  /// and the ones carrying the product's worldview say so. Without this the
  /// `[niche]` marker is only as complete as whoever last remembered it, and a
  /// fork checklist that silently omits a string is worse than none. See
  /// ADR-0022.
  test('every ARB key has a description', () {
    final arb = File('lib/l10n/app_en.arb');
    if (!arb.existsSync()) return;

    final json = jsonDecode(arb.readAsStringSync()) as Map<String, dynamic>;
    final undocumented = json.keys.where((k) => !k.startsWith('@')).where((k) {
      final meta = json['@$k'];
      return meta is! Map ||
          (meta['description'] as String?)?.isNotEmpty != true;
    }).toList();

    expect(
      undocumented,
      isEmpty,
      reason:
          'These keys have no @description, so nobody has decided whether\n'
          'they are niche-specific:\n${undocumented.join('\n')}',
    );
  });
}
