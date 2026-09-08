import 'package:feral/src/domain/run.dart';
import 'package:feral/src/engine/run_reconciler.dart';
import 'package:test/test.dart';

CampaignRun run({
  required String id,
  required DateTime startedAt,
  RunStatus status = RunStatus.active,
}) => CampaignRun(
  id: id,
  userId: 'user-1',
  campaignId: 'campaign-1',
  status: status,
  isHardened: false,
  startedAt: startedAt,
  completedAt: null,
  grade: null,
);

void main() {
  test('the earlier start wins', () {
    final result = RunReconciler.resolve(
      local: run(id: 'b', startedAt: DateTime.utc(2026, 6, 5)),
      remote: run(id: 'a', startedAt: DateTime.utc(2026, 6, 1)),
    );

    expect(result.keep.id, 'a');
    expect(result.abandon.id, 'b');
  });

  test('the earlier start wins regardless of which side it is on', () {
    final result = RunReconciler.resolve(
      local: run(id: 'a', startedAt: DateTime.utc(2026, 6, 1)),
      remote: run(id: 'b', startedAt: DateTime.utc(2026, 6, 5)),
    );

    expect(result.keep.id, 'a');
    expect(result.abandon.id, 'b');
  });

  test('an exact tie breaks on the lower id, so both devices agree', () {
    final at = DateTime.utc(2026, 6, 1, 7, 30);
    final fromA = RunReconciler.resolve(
      local: run(id: 'aaa', startedAt: at),
      remote: run(id: 'bbb', startedAt: at),
    );
    final fromB = RunReconciler.resolve(
      local: run(id: 'bbb', startedAt: at),
      remote: run(id: 'aaa', startedAt: at),
    );

    expect(fromA.keep.id, 'aaa');
    expect(fromB.keep.id, 'aaa');
  });

  test('resolving the same pair twice gives the same answer', () {
    final local = run(id: 'b', startedAt: DateTime.utc(2026, 6, 5));
    final remote = run(id: 'a', startedAt: DateTime.utc(2026, 6, 1));

    expect(
      RunReconciler.resolve(local: local, remote: remote).keep.id,
      RunReconciler.resolve(local: local, remote: remote).keep.id,
    );
  });

  test('it reports whether the local run was the one kept', () {
    final keptLocal = RunReconciler.resolve(
      local: run(id: 'a', startedAt: DateTime.utc(2026, 6, 1)),
      remote: run(id: 'b', startedAt: DateTime.utc(2026, 6, 5)),
    );
    final lostLocal = RunReconciler.resolve(
      local: run(id: 'b', startedAt: DateTime.utc(2026, 6, 5)),
      remote: run(id: 'a', startedAt: DateTime.utc(2026, 6, 1)),
    );

    expect(keptLocal.localSurvived, isTrue);
    expect(lostLocal.localSurvived, isFalse);
  });

  test('the same run on both sides is not a conflict', () {
    final same = run(id: 'a', startedAt: DateTime.utc(2026, 6, 1));
    expect(RunReconciler.isConflict(local: same, remote: same), isFalse);
  });
}
