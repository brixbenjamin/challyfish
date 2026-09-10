import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'l10n/app_localizations.dart';
import 'src/app/providers.dart';
import 'src/core/zone_provider.dart';
import 'src/data/remote/supabase_bootstrap.dart';
import 'src/niche/brand.dart';
import 'src/ui/home_router.dart';
import 'src/ui/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The Inter faces are bundled (assets/google_fonts/). Forbidding the runtime
  // fetch means a cold, offline first launch renders in Inter rather than
  // silently degrading to the platform fallback, and the app carries no
  // network dependency it did not choose.
  GoogleFonts.config.allowRuntimeFetching = false;
  tzdata.initializeTimeZones();
  await initializeSupabase();
  // The id itself is not carried anywhere: userIdProvider reads whoever the
  // session belongs to at the moment it is asked. This only guarantees there
  // is one before the first screen builds.
  await ensureAnonymousSession();
  final zone = await deviceZone();
  // Resolved once here so no screen has to await a preference mid-build.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        zoneProvider.overrideWithValue(zone),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FeralApp(),
    ),
  );
}

class FeralApp extends StatelessWidget {
  const FeralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Brand.appName,
      theme: appDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeRouter(),
    );
  }
}
