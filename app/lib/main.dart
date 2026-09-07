import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'l10n/app_localizations.dart';
import 'src/data/remote/supabase_bootstrap.dart';
import 'src/niche/brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await initializeSupabase();
  await ensureAnonymousSession();

  runApp(const ProviderScope(child: FeralApp()));
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
      home: const Scaffold(body: Center(child: Text(Brand.appName))),
    );
  }
}
