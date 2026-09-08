import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/run.dart';
import 'package:feral/src/engine/marks.dart';
import 'package:test/test.dart';

CampaignRun run(
  String id,
  String campaignId, {
  RunStatus status = RunStatus.completed,
  Grade? grade,
}) => CampaignRun(
  id: id,
  userId: 'user-1',
  campaignId: campaignId,
  status: status,
  startedAt: DateTime.utc(2026, 6, 1, 9),
  grade: grade,
);

const targets = {
  'c-killer': ['a-killer'],
  'c-both': ['a-killer', 'a-psycho'],
};

void main() {
  const marks = MarkCalculator();

  Map<String, int> earnedFor(List<CampaignRun> runs) =>
      marks.earned(runs: runs, archetypeIdsByCampaign: targets);

  test(
    'a Sovereign run earns a mark in every archetype its campaign targets',
    () {
      expect(earnedFor([run('r1', 'c-both', grade: Grade.sovereign)]), {
        'a-killer': 1,
        'a-psycho': 1,
      });
    },
  );

  test('a Passed run earns a mark too', () {
    expect(earnedFor([run('r1', 'c-killer', grade: Grade.passed)]), {
      'a-killer': 1,
    });
  });

  test('a Broken run earns nothing', () {
    expect(earnedFor([run('r1', 'c-killer', grade: Grade.broken)]), isEmpty);
  });

  test('an active run earns nothing, whatever it currently stands at', () {
    expect(
      earnedFor([run('r1', 'c-killer', status: RunStatus.active, grade: null)]),
      isEmpty,
    );
  });

  test('an abandoned run earns nothing even if it was graded', () {
    expect(
      earnedFor([
        run(
          'r1',
          'c-killer',
          status: RunStatus.abandoned,
          grade: Grade.sovereign,
        ),
      ]),
      isEmpty,
    );
  });

  test('marks accumulate across runs of the same campaign', () {
    expect(
      earnedFor([
        run('r1', 'c-killer', grade: Grade.sovereign),
        run('r2', 'c-killer', grade: Grade.passed),
      ]),
      {'a-killer': 2},
    );
  });

  test('a completed run with no grade is ignored rather than crashing', () {
    // Should not occur — the schema forbids it — but a corrupt row must not
    // take the dashboard down with it.
    expect(earnedFor([run('r1', 'c-killer', grade: null)]), isEmpty);
  });

  test('a run whose campaign targets are unknown is skipped', () {
    expect(
      earnedFor([run('r1', 'c-missing', grade: Grade.sovereign)]),
      isEmpty,
    );
  });

  test('no runs yield no marks, not a crash', () {
    expect(earnedFor(const []), isEmpty);
  });
}
