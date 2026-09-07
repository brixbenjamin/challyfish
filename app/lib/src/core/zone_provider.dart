import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

/// The device's current timezone, as a location the run engine can use.
/// Read fresh rather than cached: a user who flies changes zone mid-run.
Future<tz.Location> deviceZone() async {
  final info = await FlutterTimezone.getLocalTimezone();
  try {
    return tz.getLocation(info.identifier);
  } catch (_) {
    return tz.UTC;
  }
}
