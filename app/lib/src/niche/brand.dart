/// The brand tokens. A leaf: imports nothing from lib/src/.
///
/// The words are not here. They are in lib/l10n/app_en.arb (ADR-0022). The
/// visual system is not here either: it is in lib/src/ui/theme/, which a fork
/// re-skins by editing that directory and nothing else.
///
/// What is NOT here either, because it lives outside Dart: the bundle id (set by
/// `flutter create --org`), the iOS Info.plist display name, and the Android
/// manifest label. niche/README.md lists them.
abstract final class Brand {
  static const appName = 'Feral';
}
