import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Every user-facing word the app supplies itself. Non-nullable by config,
  /// so a screen never writes `!` and a missing delegate fails at wiring time.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
