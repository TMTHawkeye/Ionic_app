import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonIcon,
  IonSpinner,
  IonText,
  AlertController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { rocketOutline, checkmarkCircleOutline, alertCircleOutline } from 'ionicons/icons';

import { SdkLauncher } from 'sdk-launcher-plugin';

type LaunchStatus = 'idle' | 'launching' | 'success' | 'error';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon, IonSpinner, IonText],
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss'],
})
export class HomePage {
  status: LaunchStatus = 'idle';
  statusMessage = '';

  constructor(private alertController: AlertController) {
    addIcons({ rocketOutline, checkmarkCircleOutline, alertCircleOutline });
  }

  async launchSdk() {
    this.status = 'launching';
    this.statusMessage = '';

    try {
      const result = await SdkLauncher.launch({
        // TODO: replace with your real API key / license key
        apiKey: 'YOUR_SDK_API_KEY',
        extra: {
          environment: 'sandbox',
        },
      });

      if (result.success) {
        this.status = 'success';
        this.statusMessage = result.message ?? 'SDK launched successfully';
      } else {
        this.status = 'error';
        this.statusMessage = result.message ?? 'SDK failed to launch';
      }
    } catch (err: any) {
      this.status = 'error';
      this.statusMessage = err?.message ?? 'Unknown error launching SDK';

      const alert = await this.alertController.create({
        header: 'Launch failed',
        message: this.statusMessage,
        buttons: ['OK'],
      });
      await alert.present();
    }
  }
}
