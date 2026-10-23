# SmartGPS user app

This Flutter application is the user-facing client. Administration stays in the separate web console. The app reads and writes authenticated parcel, track, and device data through the SmartGPS API.

## API address

The default API URL is `http://10.0.2.2:3000/api` for the Android emulator. On a physical phone, open **Server settings** on the login screen and enter a server URL the phone can reach, such as `https://gps.example.com`. Debug builds allow HTTP for local testing; release builds require HTTPS. The app adds `/api` automatically and saves the setting on the device.

For a custom build-time default, pass:

```powershell
flutter build apk --release --dart-define=API_URL=https://gps.example.com/api
```

## Build

Install Flutter and the Android SDK, then run `flutter pub get` followed by `flutter build apk --release`. The generated APK is `build/app/outputs/flutter-apk/app-release.apk`.

Location tracking uses the device GPS while the app is active. Sharing a device requires explicitly entering a pairing code and confirming location sharing.
