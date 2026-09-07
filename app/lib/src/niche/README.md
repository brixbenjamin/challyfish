# Fork checklist

Everything a fork of this app changes, in one place, so it is written down once
rather than rediscovered. See `brand.dart` for what lives in Dart.

- Every ARB key in `lib/l10n/app_en.arb` whose `@key` description starts with
  `[niche]` — the product's vocabulary and worldview.
- `lib/src/niche/brand.dart` — the app name, color seed, and theme.
- The bundle id, set by `flutter create --org` (not stored as a single file;
  re-run the platform rename tooling or edit the platform projects directly).
- `ios/Runner/Info.plist` — `CFBundleDisplayName`.
- `android/app/src/main/AndroidManifest.xml` — `android:label`.
- The launcher icon and splash assets (per-platform, under `ios/` and
  `android/`).
- `supabase/seed/` — the content itself.
