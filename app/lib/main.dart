import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final userId = await ensureAnonymousSession();
  final zone = await deviceZone();

  runApp(
    ProviderScope(
      overrides: [
        userIdProvider.overrideWithValue(userId),
        zoneProvider.overrideWithValue(zone),
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
