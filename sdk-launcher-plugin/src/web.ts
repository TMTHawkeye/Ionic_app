import { WebPlugin } from '@capacitor/core';

import type { LaunchOptions, LaunchSnapOptions, LaunchResult, SdkLauncherPlugin } from './definitions';

export class SdkLauncherWeb extends WebPlugin implements SdkLauncherPlugin {
  async launch(options: LaunchOptions): Promise<LaunchResult> {
    console.warn('SdkLauncher.launch() has no web implementation — TruID only runs on iOS/Android.', options);
    return { error: 'Not supported on web' };
  }

  async launchSnap(options: LaunchSnapOptions): Promise<LaunchResult> {
    console.warn('SdkLauncher.launchSnap() has no web implementation — TruID only runs on iOS/Android.', options);
    return { error: 'Not supported on web' };
  }
}
