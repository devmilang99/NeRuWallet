# iOS Configuration Guide for Google & Apple Sign-In

## Steps to Complete in Xcode

### 1. Open iOS Project in Xcode

```bash
open ios/Runner.xcworkspace
```

### 2. Enable Apple Sign In Capability

1. Select **Runner** project in the left sidebar
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Search for and select **Sign in with Apple**
6. Ensure it's added to the Runner target

### 3. Configure Code Signing

1. Still in **Signing & Capabilities**, verify:
    - Team ID is set correctly
    - Bundle ID is set to: `com.example.neruwallet` (or your actual bundle ID)
    - Provisioning Profile includes the Sign in with Apple capability

### 4. Verify Runner.entitlements File

- The file `ios/Runner/Runner.entitlements` has been created with Apple Sign In entitlements
- Xcode should automatically reference this when the capability is added

### 5. Configure URL Schemes for Google Sign-In

- The URL scheme has been added to `ios/Runner/Info.plist`
- Current scheme: `com.googleusercontent.apps.722947171092-i3rav08lrj9mar7uskumpus91elmqq31`

### 6. Ensure Google Configuration is Present

1. For Google Sign-In to work on iOS, you need to ensure the URL Scheme in `Info.plist` matches your
   Google Cloud Project.
2. The current scheme is configured. If you change your Google Client ID, update the
   `CFBundleURLSchemes` in `ios/Runner/Info.plist`.

### 7. Update Bundle ID (if needed)

If you're using a different Bundle ID than `com.example.neruwallet`:

1. Update in Xcode: Runner target > General > Bundle Identifier
2. Update in `ios/Runner/Info.plist` if needed

### 8. Trust Development Certificate (for Testing)

On your iOS device:

1. Go to Settings > General > VPN & Device Management
2. Trust the developer certificate used for signing

## Testing the Setup

1. Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

2. Try Google Sign-In first - easier to debug
3. Try Apple Sign-In if Google works

## Common Issues & Solutions

### Apple Sign-In Shows "Sign in unavailable"

- **Issue**: Entitlements not properly configured
- **Solution**:
    - Verify `Runner.entitlements` exists in ios/Runner/
    - In Xcode, select Runner target > Build Settings > Code Signing Entitlements
    - Set to: `Runner/Runner.entitlements`

### Google Sign-In Fails Silently

- **Issue**: URL scheme not configured
- **Solution**:
    - Check Info.plist has CFBundleURLTypes section

### "Invalid Client" or "Keychain error"

- **Issue**: Code signing issues
- **Solution**:
    - Clean build folder: Cmd+Shift+K in Xcode
    - Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
    - Rebuild: `flutter clean && flutter run`

## After Configuration

Once everything is set up:

1. Delete the app from your test device
2. Run: `flutter run -v` to see detailed logs
3. Monitor the console for specific error messages if issues occur
