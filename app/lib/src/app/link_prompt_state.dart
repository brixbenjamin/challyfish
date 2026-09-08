import 'package:shared_preferences/shared_preferences.dart';

/// Whether the one link prompt has been used up.
///
/// ADR-0013: exactly one prompt, on the completion screen, for unlinked users.
/// Dismissal is remembered and the prompt never returns. A user who dismisses
/// reflexively is never asked again — deliberate, and the price of not nagging.
class LinkPromptState {
  LinkPromptState(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'link_prompt_dismissed';

  Future<bool> shouldPrompt({required bool isLinked}) async {
    if (isLinked) return false;
    return !(_prefs.getBool(_key) ?? false);
  }

  Future<void> markDismissed() => _prefs.setBool(_key, true);

  /// Only for account deletion, which returns the app to a first-run state.
  Future<void> reset() => _prefs.remove(_key);
}
