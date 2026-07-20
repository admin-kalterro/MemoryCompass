# Google Drive setup

MemoryCompass uses Google Sign-In + the Drive API (`drive.file` scope - the
app can only read/write files it created itself) so a user can back up their
memories and restore them on a new phone. This requires an OAuth client from
your own Google Cloud project; nobody else's client ID will work with your
app's bundle/package id, so these steps can't be baked into the repo.

## 1. Create a Google Cloud project and enable the Drive API

1. Go to https://console.cloud.google.com/ and create (or pick) a project.
2. **APIs & Services > Library** - enable the **Google Drive API**.
3. **APIs & Services > OAuth consent screen** - configure it (External user
   type is fine for testing with your own account; add the
   `.../auth/drive.file` scope).

## 2. Android OAuth client

1. **APIs & Services > Credentials > Create Credentials > OAuth client ID >
   Android**.
2. Package name: `com.kalterro.memortycompass.memory_compass` (from
   `android/app/build.gradle.kts`).
3. SHA-1 certificate fingerprint - for the debug build on this machine it's:
   ```
   3B:F6:B6:B0:D4:3B:89:08:AE:2B:27:37:68:00:1A:26:0B:42:3B:AD
   ```
   (Regenerate with `cd android && ./gradlew signingReport` if you re-key
   the debug keystore, and add another client ID with your release
   keystore's SHA-1 before shipping.)
4. No code changes are needed for Android beyond this - `google_sign_in`
   picks up the OAuth client from Google Play Services using the app's
   package name + signing certificate.

## 3. iOS OAuth client

1. **Credentials > Create Credentials > OAuth client ID > iOS**.
2. Bundle ID: `com.kalterro.memortycompass.memoryCompass` (from
   `ios/Runner.xcodeproj/project.pbxproj`).
3. Copy the generated **iOS client ID**, e.g.
   `1234567890-abc123.apps.googleusercontent.com`, and its **reversed**
   form, e.g. `com.googleusercontent.apps.1234567890-abc123`.
4. In `ios/Runner/Info.plist`, replace the placeholder
   `com.googleusercontent.apps.REPLACE_WITH_IOS_CLIENT_ID` (inside
   `CFBundleURLTypes`) with your reversed client ID.
5. Add a `GIDClientID` key to the same `Info.plist` with the (non-reversed)
   iOS client ID as its value.

## 4. Verify

Run the app, open the map, tap the cloud icon in the app bar, and tap
**Connect Google Drive**. On first connect it also runs an initial sync,
creating a `MemoryCompass` folder in the signed-in account's Drive. To test
"lost phone" recovery: uninstall/reinstall the app (or use a second device),
sign in with the same Google account from the settings screen, and tap
**Sync now** - it finds the existing `MemoryCompass` folder and downloads the
photos/pins from `manifest.json`.

## Notes / limitations

- Only files the app itself created in Drive are ever touched (`drive.file`
  scope) - it cannot browse or modify the rest of your Drive.
- Sync is manual (a "Sync now" button) and last-write-wins on conflicts;
  there's no deletion sync yet - deleting a pin on one device doesn't remove
  it from Drive or other devices.
