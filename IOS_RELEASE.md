# iOS Release Handoff

## Current Release

- App name: Discount Scanner
- Bundle ID: `com.cistemcode.discountscanner`
- Version: `1.0.5`
- Build number: `6`
- Minimum iOS version: `12.0`

## Build On The Release Mac

1. Install Flutter, Xcode, and CocoaPods.
2. From the project root, run:

```sh
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ipa --release
```

## Signing

Open `ios/Runner.xcworkspace` in Xcode if signing needs to be configured.

- Target: `Runner`
- Signing: Automatic
- Bundle Identifier: `com.cistemcode.discountscanner`
- Team: choose the Apple Developer team that owns the app record

## Store Assets

Prepared assets are in:

- `assets/phone-assets/ios-6.7/`
- `assets/phone-assets/ios-6.5/`
- `assets/phone-assets/ipad-13/`
- `assets/phone-assets/android-phone/`
- `assets/phone-assets/feature-graphic.png`

The iOS marketing icon is generated in:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`

## App Store Connect Availability

For this release, opt out of Mac distribution unless the app has been tested on Apple silicon Macs:

1. Open the app in App Store Connect.
2. Go to Pricing and Availability.
3. In iPhone and iPad Apps on Apple Silicon Mac, deselect Make this app available.
4. Save, then resubmit the iOS build.

## Preflight Checks

Run these before archiving:

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build ios --release --no-codesign
```

Note: `flutter build ios --release --no-codesign` requires a complete Xcode
installation. If it fails with `xcrun: error: unable to find utility
"xcodebuild"`, install/select Xcode first:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```
