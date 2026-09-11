import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// The bundled snapshot is a checked-in artifact, so it can be asserted on
/// directly. This is the regression test for the defect ADR-0025 was written
/// about: the file named core_content.json shipped the paid pack.
void main() {
  test('the bundled snapshot carries no paid pack bodies', () async {
    final raw =
        jsonDecode(await File('assets/seed/core_content.json').readAsString())
            as Map<String, dynamic>;

    final packs = {
      for (final p in (raw['packs'] as List).cast<Map<String, dynamic>>())
        p['id'] as String: p['is_core'] as bool,
    };
    final campaignPack = {
      for (final c in (raw['campaigns'] as List).cast<Map<String, dynamic>>())
        c['id'] as String: c['pack_id'] as String,
    };
    final actionCampaign = {
      for (final a in (raw['actions'] as List).cast<Map<String, dynamic>>())
        a['id'] as String: a['campaign_id'] as String,
    };

    final bodies = (raw['action_bodies'] as List).cast<Map<String, dynamic>>();
    expect(
      bodies,
      isNotEmpty,
      reason: 'the free pack must still ship its bodies',
    );

    final paid = bodies.where((b) {
      final campaign = actionCampaign[b['action_id'] as String];
      final pack = campaignPack[campaign];
      return packs[pack] == false;
    });
    expect(paid, isEmpty, reason: 'a paid body reached the app bundle');
  });

  test('the snapshot still carries every action as teaser', () async {
    // Titles stay public after ADR-0025, and a locked campaign must be browsable
    // offline on a first launch. Without this, a "fix" that simply dropped every
    // paid action from the snapshot would pass the test above while quietly
    // breaking offline browse.
    final raw =
        jsonDecode(await File('assets/seed/core_content.json').readAsString())
            as Map<String, dynamic>;

    final actions = (raw['actions'] as List).cast<Map<String, dynamic>>();
    final bodies = (raw['action_bodies'] as List).cast<Map<String, dynamic>>();

    final packs = {
      for (final p in (raw['packs'] as List).cast<Map<String, dynamic>>())
        p['id'] as String: p['is_core'] as bool,
    };
    final campaignPack = {
      for (final c in (raw['campaigns'] as List).cast<Map<String, dynamic>>())
        c['id'] as String: c['pack_id'] as String,
    };

    final paidActions = actions.where(
      (a) => packs[campaignPack[a['campaign_id'] as String]] == false,
    );
    expect(
      paidActions,
      isNotEmpty,
      reason: 'a locked pack must still be browsable offline',
    );
    expect(
      bodies.length,
      lessThan(actions.length),
      reason: 'every action ships; only the free pack ships its copy',
    );
  });
}
