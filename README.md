# Ripple – Water Tracker

Hydration that follows you.

Ripple is an open-source Swift 6 + SwiftUI water tracker. Log from the app, widgets, Control Center, Watch, Siri, Live Activity, or notifications. SwiftData is the source of truth. HealthKit is a projection. CloudKit syncs through an App Group store.

## Requirements

- Xcode 26 or newer
- Apple Developer account (for device, HealthKit, CloudKit, App Groups)
- No third-party packages

## Start in under 30 minutes

1. Copy `Config/Ripple.xcconfig.example` to `Config/Ripple.xcconfig`.
2. Set `DEVELOPMENT_TEAM` to your Team ID. Leave the default bundle, App Group, and iCloud IDs or replace them everywhere:
   - Bundle ID: `de.stefansturm.ripple`
   - App Group: `group.de.stefansturm.ripple`
   - iCloud container: `iCloud.de.stefansturm.ripple`
3. In [Apple Developer](https://developer.apple.com/account):
   - Create the App IDs for iOS (`de.stefansturm.ripple`), widgets (`.widgets`), Watch (`.watchkitapp`), Watch widgets (`.watchkitapp.widgets`), Mac (`.mac`), tvOS (`.tv`), visionOS (`.vision`).
   - Enable App Groups, iCloud (CloudKit), HealthKit (iOS + Watch), Push Notifications (CloudKit).
   - Create the App Group and iCloud container matching the xcconfig values.
4. Generate the Xcode project (already checked in after `xcodegen`):

   ```bash
   xcodegen generate
   ```

5. Open `Ripple.xcworkspace`, select scheme `RippleiOS`, pick a simulator or your device, Run.
6. First launch on a signed device will create the CloudKit schema in **Development**. Deploy it to Production from CloudKit Console before TestFlight/App Store.

Without a paid team the iOS simulator still runs: `SharedContainer` falls back from App Group + CloudKit → App Group local → in-memory. Settings shows the sync status.

## Architecture

Feature-first Clean MVVM. See `Docs/ADR`.

```
Apps + Extensions     Composition root
RippleFeatures        Views + @Observable view models
RippleUI              Tokens, components, motion
RippleIntentsCore     App Intents + Shortcuts
RippleDomain          Entities, use cases, ports
RippleData            SwiftData, CloudKit, HealthKit, notifications
```

`LogIntake` is the only write path for every surface.

## Tests

Domain and Data tests run without an app target:

```bash
swift test --package-path Packages/RippleDomain
swift test --package-path Packages/RippleData
swift test --package-path Packages/RippleIntentsCore
```

CI should run those three plus `xcodebuild test` for `RippleiOS` when a simulator is available.

## Debug vs Release stores

Optional debug App Group: `group.de.stefansturm.ripple.debug`. CloudKit Development vs Production is selected by the signing environment; do not mix them on one device.

## License

MIT. See `LICENSE`.
