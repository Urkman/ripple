# Contributing to Ripple

Ripple is MIT-licensed. Use your own Apple Developer IDs.

1. Copy `Config/Ripple.xcconfig.example` to `Config/Ripple.xcconfig`.
2. Set `DEVELOPMENT_TEAM` to your Team ID.
3. In Apple Developer / Xcode:
   - App ID `de.stefansturm.ripple` (plus watch, widgets, mac, tv, vision suffixes)
   - App Group `group.de.stefansturm.ripple`
   - iCloud container `iCloud.de.stefansturm.ripple`
4. Enable HealthKit on the iOS and watchOS App IDs.
5. Deploy the CloudKit schema from the Development environment once the app has launched against your container.
6. Open `Ripple.xcworkspace`, select the `RippleiOS` scheme, run on a simulator or device.

Do not add third-party dependencies. Keep write paths inside Domain use cases.
