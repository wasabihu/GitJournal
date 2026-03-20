# Building Instructions

This file is kept as the alternative English version. For the primary Chinese build guide, see [BUILD.md](./BUILD.md).

- It's best to just work on this on Android. The iOS setup is more complicated, and the current repository workflow is centered on Android development.

## Environment Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install) through the official guidelines.
1. As part of the Flutter installation, you will also need to install [Android Studio](https://developer.android.com/studio).
1. Use [AVD Manager](https://developer.android.com/studio/run/managing-avds) from Android Studio to create a device for local development.
1. Run `flutter run --flavor dev --debug` to connect to an available device and launch the app.

   1. Or run `flutter build apk --flavor dev --debug` and find the APK under `build/app/outputs/flutter-apk/`.

1. For production APKs:

   1. Universal release APK: `flutter build apk --flavor prod --release`
   1. Smaller per-device release APKs: `flutter build apk --flavor prod --release --split-per-abi`
   1. The generated split APKs are written to `build/app/outputs/flutter-apk/` as `app-arm64-v8a-prod-release.apk`, `app-armeabi-v7a-prod-release.apk`, and `app-x86_64-prod-release.apk`

1. Once the app appears on the emulator, the environment is ready. A good place to start exploring is [lib/app.dart](./lib/app.dart).

## Trouble Shooting

This section is currently a placeholder and can be expanded later with common setup issues.

## IDE Setup

VS Code has great Flutter support, but you need to add args to `launch.json`. Example:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "dev"]
    }
  ]
}
```

### Debugging with breakpoints

To use Android Studio's debugger with breakpoints:

- Open your local repo with Android Studio.
- Android Studio should already have a Flutter Run Configuration named `main.dart`, visible at the top of the window.
- Edit this run configuration. For `Build flavor`, enter `dev` and save the configuration.
- On the top bar of Android Studio, with `main.dart` selected, click the debug button. Its tooltip is usually `Debug main.dart`.
