# Android implementation acceptance

Use this reference after automated checks pass to verify behavior on a real
Android emulator or connected device. Adapt Gradle task names, package ID,
activity, and device serial to the repository.

## Build and launch

```sh
adb devices
./gradlew :<module>:assemble<Variant> --console=plain
./gradlew :<module>:install<Variant> --console=plain
adb -s <serial> shell cmd package resolve-activity --brief <package>
adb -s <serial> shell am start -n <package>/<activity>
```

If the project uses a different build system or launcher, follow its
architecture instructions and record the exact command.

## Drive a documented flow

1. Start from a deterministic seed or clean state defined by the project.
2. Navigate using visible labels and the UI tree, not guessed screenshot
   coordinates.
3. Dump the UI tree before selecting a target:

   ```sh
   adb -s <serial> exec-out uiautomator dump /dev/tty > /tmp/ui.xml
   ```

4. Derive tap bounds from the target node. If a target is in a scrollable
   region, scroll, dump again, and confirm the node before tapping.
5. Exercise the success path, cancellation/back path, validation error, empty
   state, offline/stale state when supported, and destructive recovery path.
6. Capture screenshots after meaningful states:

   ```sh
   adb -s <serial> exec-out screencap -p > /tmp/android-surface.png
   ```

7. Capture crashes and relevant logs:

   ```sh
   adb -s <serial> logcat -c
   adb -s <serial> logcat -b crash
   adb -s <serial> logcat -d > /tmp/android-logcat.txt
   ```

## Acceptance matrix

For each implemented stable ID, record:

| Surface | Launch/entry | Primary outcome | Cancel/back | Loading/empty/error | Accessibility | Adaptive sizes/theme | Evidence |
|---|---|---|---|---|---|---|---|
| `[id]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[path or run]` |

## Review rules

- Compare screenshots to written semantic contracts and reference images for
  hierarchy, state, and interaction—not pixel identity with another platform.
- Verify stable collection keys, no duplicate writes, correct amount/unit
  formatting, and persistence after relaunch where documented.
- Check dark theme and font scaling; ensure actions and values remain reachable.
- Check TalkBack semantics for labels, selected/disabled state, adjustable
  controls, order, and destructive consequences.
- Record emulator/API/device configuration and every unverified flow.
- A passing build or screenshot does not replace interaction testing.
