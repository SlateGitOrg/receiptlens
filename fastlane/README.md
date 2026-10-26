# Fastlane lanes (documented, not wired into CI)

This project ships **documented** Fastlane lanes for release builds and store
submission. They are intentionally **not** part of `.github/workflows/ci.yml`
— running them requires real signing certificates / provisioning profiles /
store API credentials that must never live in this repository or in CI
secrets. Treat everything below as the release runbook, with signing material
supplied out-of-band by whoever owns signing.

## Layout

```
fastlane/
  README.md      This file.
  Fastfile        Android + iOS lane definitions (documented below).
  Appfile         Placeholder app identifiers - replace before real use.
```

## Android lanes

```bash
cd android
bundle exec fastlane android test      # unit tests via Gradle (no signing needed)
bundle exec fastlane android beta      # build + upload to Play Console internal track
bundle exec fastlane android release   # build + promote to production
```

`beta`/`release` require:

- `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` — release signing.
- `PLAY_STORE_JSON_KEY_PATH` — a Google Play service account key with release-manager access.

## iOS lanes

```bash
cd ios
bundle exec fastlane ios test          # xcodebuild test (simulator, no signing needed)
bundle exec fastlane ios beta          # build + upload to TestFlight
bundle exec fastlane ios release       # submit to App Store review
```

`beta`/`release` require:

- An App Store Connect API key (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`).
- A `match` git-crypt repo (or manual provisioning profiles) for distribution signing.

## Why this isn't in CI

- No signing certificate, keystore, or App Store Connect key is stored in
  this repository or as a CI secret.
- `flutter analyze` + `flutter test` (the CI job) validate the app's logic
  and run entirely offline; they don't require a signed build.
- Store submission is a deliberate, human-triggered action in a real release
  process, not something that should happen automatically on every push.
