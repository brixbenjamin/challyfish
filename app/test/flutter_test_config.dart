import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Runs once before every test file in this package.
///
/// The app bundles its Inter faces and forbids runtime fetching (offline-first,
/// spec section 3.5). The suite holds the same line, so a test can never pass
/// because it quietly downloaded a font, and CI never depends on the network.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
