export interface LaunchOptions {
  /** TruID application/API token (was `appToken` in the RN bridge) */
  apiKey: string;
  /** TruID API endpoint, e.g. https://api.truid.example.com */
  endPoint?: string;
  /** Additional provider-specific parameters */
  extra?: Record<string, unknown>;
}

export interface LaunchSnapOptions extends LaunchOptions {
  /** Application id required for the "snap" flow */
  applicationId: number;
}

export interface LaunchResult {
  success?: boolean;
  message?: string;
  sessionId?: string;
  verificationStatus?: string;
  error?: string;
}

export interface SdkLauncherPlugin {
  /**
   * Full TruID flow: face liveness, document capture, extraction,
   * authenticity, backside capture, ID-to-selfie match, fingerprint capture.
   * Mirrors MainActivity.launchTruID() from the React Native app.
   */
  launch(options: LaunchOptions): Promise<LaunchResult>;

  /**
   * "Snap" TruID flow tied to a specific applicationId.
   * Mirrors MainActivity.launchSnapTruID() from the React Native app.
   */
  launchSnap(options: LaunchSnapOptions): Promise<LaunchResult>;
}
