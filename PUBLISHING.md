# Publishing to pub.dev

Checklist for publishing `otp_forge`.

## Pre-publish

1. **Version** — Bump `version` in `pubspec.yaml` (semver).
2. **Changelog** — Add an entry under `CHANGELOG.md` for the release.
3. **Analyze & test**
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```
4. **Example app** — Run the demo to verify integration:
   ```bash
   cd example && flutter run
   ```

## Publish

```bash
dart pub login
dart pub publish
```

Confirm when prompted. Publishing is irreversible for a given version.

## pub.dev score tips

| Requirement | Status |
|---|---|
| Valid `pubspec.yaml` (description ≥ 60 chars) | ✅ |
| `homepage` / `repository` | ✅ |
| `issue_tracker` | ✅ |
| Open-source license (`LICENSE`) | ✅ MIT |
| `README.md` with usage examples | ✅ |
| `CHANGELOG.md` | ✅ |
| `example/` directory | ✅ |
| `flutter analyze` — no issues | Run before publish |
| Platform support declared | Android plugin |

## After publish

- Tag the release: `git tag v0.1.0 && git push origin v0.1.0`
- Create a GitHub release with notes from `CHANGELOG.md`
- Verify the package page: `https://pub.dev/packages/otp_forge`
