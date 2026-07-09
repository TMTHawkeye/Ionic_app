import Foundation
import Capacitor
import TruID
import Alamofire
import SwiftUI // Required for UIHostingController to bridge SwiftUI to UIKit

/**
 * SdkLauncherPlugin
 *
 * Bridges JS -> native to initialize and launch the TruID iOS SDK.
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
    
    struct GenerateTokenRequest: Codable {
        let token: String
        let platform: String
    }

    struct GenerateTokenResponse: Codable {
        let token: String
    }
    
    private let API_URL = "https://staging-api.truid.ai"
    private let CLIENT_SECRET = "D2kfiNwj.UGDhegFB3e8hCmREAnHVWvj8r6Z9MSlb" // truid staging
    var token: String?
    var session: TruID.SessionResult?
    var error: String? = nil
    
    func generateToken(recaptchaToken: String, success: @escaping (AFDataResponse<GenerateTokenResponse>) -> Void) {
        DispatchQueue(label: "ai.truid.sdkdemotruidapiqueue").async { [self] in
            let headers: HTTPHeaders = [
                "Authorization": "Api-Key \(CLIENT_SECRET)"
            ]
            let payload = GenerateTokenRequest(token: recaptchaToken, platform: "ios")
            AF.request(
                "\(API_URL)/generate-token/",
                method: .post,
                parameters: payload,
                headers: headers
            )
            .responseDecodable(of: GenerateTokenResponse.self) { response in
                print("DEBUG:", response.data?.base64EncodedString() ?? "")
                if let error = response.error {
                    print("Error generating token: \(error)")
                } else {
                    print("-----decodeable")
                    print(response.value!)
                    self.token = response.value!.token
                    success(response)
                }
            }
        }
    }

    @objc func launch(_ call: CAPPluginCall) {
        let apiKey = call.getString("apiKey") ?? ""
        let extra = call.getObject("extra") ?? [:]

        DispatchQueue.main.async {
            // Guard that Capacitor's current view controller is available
            guard let rootVC = self.bridge?.viewController else {
                call.reject("No root view controller available to present the SDK from")
                return
            }

            print("SdkLauncher(iOS): Fetching token...")

            // 1. Asynchronously fetch your backend session token
            self.generateToken(recaptchaToken: "") { response in
                guard let responseValue = response.value else {
                    call.reject("Failed to generate network token from API")
                    return
                }
                
                let fetchedToken = responseValue.token
                self.token = fetchedToken
                
                print("SdkLauncher(iOS): Token fetched successfully. Launching TruID SDK...")

                // 2. Initialize your SwiftUI verification interface
                let truidView = TruidMain(
                    token: fetchedToken,
                    API_URL: self.API_URL,
                    face_liveness: true,
                    document_capture: true,
                    extract_data: true,
                    document_authenticity: true,
                    document_backside_capture: true,
                    id_to_selfie_matching: true,
                    fingerprint_capture: true,
                    fingerprint_selection: true,
                    fingerprint_to_scan: .LEFT_4_RIGHT_4,
                    fingerprint_instruction_popup: true,
                    enableLanguageSelect: true,
                    enableHelpScreens: true,
                    enableReportScreen: true,
                    isTestAccount: false,
                    themeColor: .blue,
                    success: { sessionResult in
                        self.session = sessionResult
                        self.token = nil
                        self.error = nil
                        self.sdkReady = false
                        
                        // Clean up UI and return to Ionic layer
                        rootVC.dismiss(animated: true) {
                            call.resolve([
                                "success": true,
                                "sessionId": sessionResult.id
                            ])
                        }
                    },
                    failure: { sessionId, error in
                        print(sessionId, error)
                        self.token = nil
                        self.error = error.message
                        self.sdkReady = false
                        
                        // Clean up UI and notify Ionic of error
                        rootVC.dismiss(animated: true) {
                            call.reject("TruID verification failed: \(error.message)", nil, nil)
                        }
                    }
                )
                
                // 3. Wrap your SwiftUI view inside a UIKit container
                let hostingController = UIHostingController(rootView: truidView)
                hostingController.modalPresentationStyle = .fullScreen
                
                // 4. Present full-screen over the native app window
                rootVC.present(hostingController, animated: true, completion: nil)
                
                self.sdkReady = true
            }
        }
    }

    @objc func isReady(_ call: CAPPluginCall) {
        call.resolve(["ready": sdkReady])
    }
}
