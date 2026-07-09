package com.example.sdklauncher

import androidx.activity.result.ActivityResultLauncher
import com.androidnetworking.AndroidNetworking
import com.androidnetworking.common.Priority
import com.androidnetworking.error.ANError
import com.androidnetworking.interfaces.JSONObjectRequestListener
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.truid.android.AuthenticateWithTruID
import com.truid.android.TruID
import com.truid.android.vision.FingerprintOptions
import com.truid.android.vision.FingersToScan
import org.json.JSONObject

/**
 * SdkLauncherPlugin
 *
 * Capacitor port of the React Native bridge (CalendarModule.kt + MainActivity.kt).
 * Same two flows are exposed to JS as `launch()` (full flow) and `launchSnap()`
 * (snap flow tied to an applicationId).
 */
@CapacitorPlugin(name = "SdkLauncher")
class SdkLauncherPlugin : Plugin() {

    // Must be registered before the host Activity reaches STARTED, so we do it in load().
    private lateinit var authenticateUser: ActivityResultLauncher<AuthenticateWithTruID.Input>

    // Capacitor's PluginCall isn't itself Parcelable-safe across process death, but for the
    // in-memory duration of this activity result round trip this mirrors the RN bridge's
    // static `reactNativeCallback` field.
    private var pendingCall: PluginCall? = null

    override fun load() {
        super.load()
        authenticateUser = activity.registerForActivityResult(AuthenticateWithTruID()) { result ->
            val call = pendingCall
            pendingCall = null

            if (call == null) return@registerForActivityResult

            val ret = JSObject()
            ret.put("sessionId", result.sessionID)
            ret.put("verificationStatus", result.verificationStatus?.toString())
            ret.put("error", result.error)
            call.resolve(ret)
        }
    }

    @PluginMethod
    fun launch(call: PluginCall) {
        val appToken = call.getString("apiKey")
        val endPoint = call.getString("endPoint")

        if (appToken.isNullOrEmpty() || endPoint.isNullOrEmpty()) {
            call.reject("apiKey and endPoint are required")
            return
        }

        call.setKeepAlive(true) // keep the call alive across the activity-result round trip
        pendingCall = call

        TruID.setAPILink(endPoint)
        generateToken(apiKey = appToken, endPoint = endPoint, onSuccess = { token ->
            activity.runOnUiThread {
                authenticateUser.launch(
                    AuthenticateWithTruID.Input(
                        token = token,
                        enableFaceLiveness = true,
                        enableOnDeviceLiveness = true,
                        enableDocumentCapture = true,
                        enableExtractData = true,
                        enableDocumentAuthenticity = true,
                        enableDocumentBacksideCapture = true,
                        enableIDtoSelfieMatching = true,
                        enableVerisysVerification = false,
                        enableFingerSelection = false,
                        enableFingerprintCapture = true,
                        enablePersonalInformationVerification = false,
                        enableMobileNumberVerification = false,
                        enableUndertaking = false,
                        enableAccountOptions = false,
                        enableAgentVerification = false,
                        displayHelpScreens = true,
                        fingerprintOptions = FingerprintOptions(
                            fingersToScan = FingersToScan.LEFT_4_Right_4,
                            minimumNIST = 30,
                            displayFingerprintResults = false
                        ),
                        enableReportScreen = false,
                        disableLocationCapture = false,
                    )
                )
            }
        }, onError = { error ->
            pendingCall = null
            call.reject(error)
        })
    }

    @PluginMethod
    fun launchSnap(call: PluginCall) {
        val appToken = call.getString("apiKey")
        val endPoint = call.getString("endPoint")
        val applicationId = call.getInt("applicationId")

        if (appToken.isNullOrEmpty() || endPoint.isNullOrEmpty() || applicationId == null) {
            call.reject("apiKey, endPoint and applicationId are required")
            return
        }

        val appId: Int = applicationId

        call.setKeepAlive(true)
        pendingCall = call

        TruID.setAPILink(endPoint)
        generateToken(apiKey = appToken, endPoint = endPoint, onSuccess = { token ->
            activity.runOnUiThread {
                authenticateUser.launch(
                    AuthenticateWithTruID.Input(
                        token = token,
                        enableFaceLiveness = true,
                        enableOnDeviceLiveness = false,
                        enableDocumentCapture = true,
                        enableExtractData = false,
                        enableDocumentAuthenticity = false,
                        enableDocumentBacksideCapture = true,
                        enableIDtoSelfieMatching = true,
                        enableVerisysVerification = false,
                        enableFingerSelection = false,
                        enableFingerprintCapture = true,
                        enablePersonalInformationVerification = false,
                        enableMobileNumberVerification = false,
                        enableUndertaking = false,
                        enableAccountOptions = false,
                        enableAgentVerification = false,
                        displayHelpScreens = true,
                        fingerprintOptions = FingerprintOptions(
                            fingersToScan = FingersToScan.LEFT_4_Right_4,
                            minimumNIST = 30,
                            displayFingerprintResults = false
                        ),
                        enableReportScreen = false,
                        disableLocationCapture = false,
                        applicationId = appId,
                    )
                )
            }
        }, onError = { error ->
            pendingCall = null
            call.reject(error)
        })
    }

    private fun generateToken(
        apiKey: String,
        endPoint: String,
        onSuccess: (token: String) -> Unit,
        onError: (error: String) -> Unit,
    ) {
        val defaultErrorMessage = "Error while generating token."

        AndroidNetworking.post("$endPoint/generate-token/")
            .addHeaders("Authorization", "Api-Token $apiKey")
            .setTag("get-token")
            .setPriority(Priority.HIGH)
            .build()
            .getAsJSONObject(object : JSONObjectRequestListener {
                override fun onResponse(response: JSONObject?) {
                    val token = response?.optString("token")
                    if (token.isNullOrEmpty()) onError(defaultErrorMessage) else onSuccess(token)
                }

                override fun onError(anError: ANError?) {
                    onError(anError?.errorBody ?: defaultErrorMessage)
                }
            })
    }
}
