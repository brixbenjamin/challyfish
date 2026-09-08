import 'package:feral/src/app/link_prompt_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('an unlinked user who has never been asked is prompted', () async {
    final state = LinkPromptState(await SharedPreferences.getInstance());
    expect(await state.shouldPrompt(isLinked: false), isTrue);
  });

  test('a linked user is never prompted', () async {
    final state = LinkPromptState(await SharedPreferences.getInstance());
    expect(await state.shouldPrompt(isLinked: true), isFalse);
  });

  test('dismissal is remembered', () async {
    final state = LinkPromptState(await SharedPreferences.getInstance());
    await state.markDismissed();
    expect(await state.shouldPrompt(isLinked: false), isFalse);
  });

  test('dismissal survives a restart', () async {
    var state = LinkPromptState(await SharedPreferences.getInstance());
    await state.markDismissed();

    // A new instance over the same store is what a relaunch looks like.
    state = LinkPromptState(await SharedPreferences.getInstance());
    expect(await state.shouldPrompt(isLinked: false), isFalse);
  });

  test('a second completed campaign does not re-ask', () async {
    final state = LinkPromptState(await SharedPreferences.getInstance());
    expect(await state.shouldPrompt(isLinked: false), isTrue);
    await state.markDismissed();

    // Second completion, weeks later.
    expect(
      await state.shouldPrompt(isLinked: false),
      isFalse,
      reason: 'ADR-0013: asked once, then never again',
    );
  });

  test('reset re-arms it, for account deletion only', () async {
    final state = LinkPromptState(await SharedPreferences.getInstance());
    await state.markDismissed();

    await state.reset();

    expect(await state.shouldPrompt(isLinked: false), isTrue);
  });
}
