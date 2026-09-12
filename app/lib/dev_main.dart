import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'l10n/app_localizations.dart';
import 'src/dev/balance_playground.dart';
import 'src/ui/theme/theme.dart';

/// A debug entrypoint for the balance playground, and nothing else.
///
///     flutter run -t lib/dev_main.dart
///
/// Deliberately not reachable from the app: no route, no debug menu, no
/// kDebugMode branch in a shipped widget tree. It also starts no Supabase
/// client and creates no session — the playground's world is in memory, so
/// there is nothing here that can touch a real user's data.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  // The balance dates every log in a timezone, so the database must be loaded
  // even though the playground pins itself to UTC.
  tzdata.initializeTimeZones();

  runApp(
    MaterialApp(
      // The real theme: the radar reads its archetype hues from a theme
      // extension, so a Material default would draw a figure that does not
      // ship. Localisations for the same reason — the radar's screen-reader
      // summary is looked up, not literal.
      theme: appDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: const BalancePlayground(),
    ),
  );
}
