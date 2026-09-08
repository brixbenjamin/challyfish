import 'dart:io';

import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/remote/seed_snapshot.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/diagnostic_repository.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/diagnostic.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Stands in for a phone in airplane mode: every call fails the way a real one
/// does, rather than quietly returning nothing.
class OfflineContentApi implements ContentApi {
  int attempts = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async {
    attempts++;
    throw const SocketException('offline');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  final berlin = tz.getLocation('Europe/Berlin');

  late FeralDatabase db;
  late OfflineContentApi api;
  late ContentRepository content;

  DateTime at(int day, int hour) =>
      tz.TZDateTime(berlin, 2026, 6, day, hour).toUtc();

  ProgressRepository progressAt(DateTime now) =>
      ProgressRepository(db: db, clock: FixedClock(now), zone: berlin);

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    api = OfflineContentApi();
    content = ContentRepository(db: db, api: api);

    // The bundled snapshot is the whole reason a first launch works with no
    // signal. It is read from the real checked-in asset, not a fixture.
    await SeedSnapshotLoader(
      db: db,
      content: content,
      readSnapshot: () => File('assets/seed/core_content.json').readAsString(),
    ).loadIfEmpty();
  });

  tearDown(() => db.close());

  test('a failed pull is never fatal', () async {
    // The router wraps this; the point here is that it really does throw, so
    // the wrapping is load-bearing rather than decorative.
    await expectLater(content.pull(), throwsA(isA<SocketException>()));
    expect(api.attempts, greaterThan(0));
    expect(await content.campaigns(), isNotEmpty);
  });

  test('a fresh install with no network reaches a graded run', () async {
    // 1. Onboarding has an instrument to show.
    final diagnostic = DiagnosticRepository(
      db: db,
      content: content,
      clock: FixedClock(at(1, 8)),
    );
    final questions = await diagnostic.questions();
    expect(questions, hasLength(8));
    expect(questions.every((q) => q.options.length == 2), isTrue);

    // 2. Answering it produces a weakest archetype and a real recommendation.
    final stored = await diagnostic.submit(
      userId: 'u',
      picks: [
        for (final q in questions)
          DiagnosticPick(questionId: q.id, optionId: q.options.first.id),
      ],
    );
    final recommended = await content.campaignById(
      stored.recommendedCampaignId,
    );
    expect(recommended, isNotNull);

    // 3. Starting it gives a run with a day-1 action.
    final run = await progressAt(
      at(1, 9),
    ).startRun(userId: 'u', campaignId: recommended!.id, isUnlocked: true);
    expect(await content.actionFor(recommended.id, 1), isNotNull);

    // 4. The whole campaign can be committed and reported, day by day.
    for (var day = 1; day <= recommended.lengthDays; day++) {
      final action = await content.actionFor(recommended.id, day);
      expect(action, isNotNull, reason: 'day $day has a cached action');

      final repo = progressAt(at(day, 20));
      await repo.commitToday(run: run, dayIndex: day, actionId: action!.id);
      await repo.report(
        run: run,
        dayIndex: day,
        actionId: action.id,
        outcome: Outcome.done,
      );
    }

    // 5. The final day completes and grades.
    final grade = await progressAt(
      at(recommended.lengthDays, 21),
    ).completeRunIfFinished(run: run, campaign: recommended);
    expect(grade, Grade.sovereign);

    // Nothing above touched a working network.
    expect(
      api.attempts,
      0,
      reason: 'no path in the first run reaches for the network',
    );
  });

  test(
    'the run survives being read back, as it would across a restart',
    () async {
      final diagnostic = DiagnosticRepository(
        db: db,
        content: content,
        clock: FixedClock(at(1, 8)),
      );
      final questions = await diagnostic.questions();
      final stored = await diagnostic.submit(
        userId: 'u',
        picks: [
          for (final q in questions)
            DiagnosticPick(questionId: q.id, optionId: q.options.last.id),
        ],
      );

      expect(await diagnostic.hasCompleted('u'), isTrue);
      expect(
        (await diagnostic.latestFor('u'))!.recommendedCampaignId,
        stored.recommendedCampaignId,
      );

      final campaign = (await content.campaignById(
        stored.recommendedCampaignId,
      ))!;
      await progressAt(
        at(1, 9),
      ).startRun(userId: 'u', campaignId: campaign.id, isUnlocked: true);

      expect(
        (await progressAt(at(2, 9)).activeRun('u'))?.campaignId,
        campaign.id,
      );
    },
  );
}
