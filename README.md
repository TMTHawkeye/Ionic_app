# my-app — Ionic + Capacitor "Launch SDK" example

An Ionic Angular (standalone components) app with a single screen (`HomePage`)
containing a **Launch SDK** button. Tapping it calls a custom Capacitor plugin
(`sdk-launcher-plugin`) that bridges to native iOS (Swift) and Android (Java)
code where you plug in your real third-party SDK.

## Project layout

```
my-app/
├── src/                          # Ionic Angular app
│   └── app/home/                 # Screen with the "Launch SDK" button
├── sdk-launcher-plugin/          # Local Capacitor plugin
│   ├── src/                      # TS interface + web stub
│   ├── ios/Plugin/               # Swift native implementation
│   └── android/.../              # Java native implementation
├── capacitor.config.ts
└── package.json
```

## 1. Install dependencies

```bash
npm install
```

This pulls in `sdk-launcher-plugin` as a local `file:` dependency automatically.

## 2. Build the plugin (once, and after any plugin change)

```bash
cd sdk-launcher-plugin
npm install
npm run build
cd ..
```

## 3. Build the web app

```bash
npm run build
```

## 4. Add native platforms

```bash
npx cap add ios
npx cap add android
npx cap sync
```

## 5. Wire in your real SDK

- **iOS**: edit `sdk-launcher-plugin/ios/Plugin/SdkLauncherPlugin.swift`
  - Add the SDK's CocoaPod to `SdkLauncherPlugin.podspec` (or your app's `Podfile` if it doesn't distribute via CocoaPods).
  - Replace the `// TODO` block in `launch(_:)` with the real init/present calls.
- **Android**: edit `sdk-launcher-plugin/android/src/main/java/com/example/sdklauncher/SdkLauncherPlugin.java`
  - Add the SDK's Maven dependency to `sdk-launcher-plugin/android/build.gradle`.
  - Replace the `// TODO` block in `launch()` with the real init/launch calls.
- Re-run `npx cap sync` after native changes.

## 6. Run on a device/simulator

```bash
npx cap open ios       # opens Xcode
npx cap open android   # opens Android Studio
```

Build/run from Xcode or Android Studio as usual.

## How the button works

`src/app/home/home.page.ts` calls:

```ts
import { SdkLauncher } from 'sdk-launcher-plugin';

await SdkLauncher.launch({ apiKey: 'YOUR_SDK_API_KEY', extra: { environment: 'sandbox' } });
```

This resolves through Capacitor's plugin bridge to whichever native
implementation is running (`SdkLauncherPlugin.swift` on iOS,
`SdkLauncherPlugin.java` on Android). On web it just logs a warning, since
native SDKs generally don't have a web equivalent.

## Notes

- The plugin currently contains **stub** launch logic (it just logs and
  resolves `success: true`) so the app runs end-to-end before you've wired up
  a real SDK. Swap in the real calls per the TODOs above.
- If your SDK requires additional permissions (camera, location, etc.), add
  them to `ios/App/App/Info.plist` and `android/app/src/main/AndroidManifest.xml`
  after running `cap add`.
