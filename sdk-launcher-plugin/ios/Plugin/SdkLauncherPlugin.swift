import Foundation
import Capacitor

// TODO: import your actual SDK, e.g.:
// import YourSDK

/**
 * SdkLauncherPlugin
 *
 * Bridges JS -> native to initialize and launch a third-party iOS SDK.
 * Fill in the TODO sections with the real SDK calls.
 */
@objc(SdkLauncherPlugin)
public class SdkLauncherPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "SdkLauncherPlugin"
    public let jsName = "SdkLauncher"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "launch", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isReady", returnType: CAPPluginReturnPromise)
    ]

    private var sdkReady = false

    @objc func launch(_ call: CAPPluginCall) {
        let apiKey = call.getString("apiKey") ?? ""
        let extra = call.getObject("extra") ?? [:]

        DispatchQueue.main.async {
            guard let rootVC = self.bridge?.viewController else {
                call.reject("No root view controller available to present the SDK from")
                return
            }

            // -----------------------------------------------------------------
            // TODO: Replace this block with your actual SDK initialization
            // and launch/present call. Typical pattern:
            //
            //   YourSDK.configure(apiKey: apiKey, options: extra)
            //   YourSDK.shared.present(from: rootVC) { result in
            //       self.sdkReady = true
            //       call.resolve([
            //           "success": true,
            //           "message": "SDK launched"
            //       ])
            //   }
            // -----------------------------------------------------------------

            print("SdkLauncher(iOS): launching SDK with apiKey=\(apiKey), extra=\(extra)")
            self.sdkReady = true

            call.resolve([
                "success": true,
                "message": "SDK launch stub executed on iOS — wire up your real SDK in SdkLauncherPlugin.swift"
            ])
        }
    }

    @objc func isReady(_ call: CAPPluginCall) {
        call.resolve(["ready": sdkReady])
    }
}
