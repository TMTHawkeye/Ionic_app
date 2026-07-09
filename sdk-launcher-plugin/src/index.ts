import { registerPlugin } from '@capacitor/core';

import type { SdkLauncherPlugin } from './definitions';

const SdkLauncher = registerPlugin<SdkLauncherPlugin>('SdkLauncher', {
  web: () => import('./web').then((m) => new m.SdkLauncherWeb()),
});

export * from './definitions';
export { SdkLauncher };
