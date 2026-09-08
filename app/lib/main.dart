import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'l10n/app_localizations.dart';
import 'src/app/providers.dart';
import 'src/core/zone_provider.dart';
import 'src/data/remote/supabase_bootstrap.dart';
import 'src/niche/brand.dart';
import 'src/ui/home_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: Brand.theme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeRouter(),
    );
  }
}
