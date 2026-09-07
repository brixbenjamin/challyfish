import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'src/niche/brand.dart';

void main() => runApp(const FeralApp());

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
