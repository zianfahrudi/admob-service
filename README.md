# Admob Service

A reusable Flutter package for easy Google Mobile Ads integration.

## Features

- **Decoupled Configuration**: Use `AdConfig` to set Ad Unit IDs dynamically.
- **Easy-to-use AdService**: Singleton service to manage Interstitial and Rewarded ads with automatic preloading.
- **BannerAdWidget**: A drop-in widget to display banner ads with automatic loading and error handling.

## Getting Started

### 1. Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  admob_service:
    path: # path to your local package
```

**Or via Git:**

```yaml
dependencies:
  admob_service:
    git:
      url: https://github.com/zianfahrudi/admob-service.git
      ref: master # Optional: branch, release tag, or commit hash
```

### 2. Initialization

Initialize the service in your `main.dart` with your Ad Unit IDs:

```dart
import 'package:admob_service/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AdService.instance.initialize(
    const AdConfig(
      showAds: true, // Use this for paid/premium logic to disable ads
      bannerAdId: 'YOUR_BANNER_AD_ID',
      interstitialAdId: 'YOUR_INTERSTITIAL_AD_ID',
      rewardAdId: 'YOUR_REWARDED_AD_ID',
    ),
  );

  runApp(const MyApp());
}
```

## Usage

### Showing Banner Ads

Place `BannerAdWidget` anywhere in your widget tree. It handles loading automatically.

```dart
Column(
  children: [
    Text('Content'),
    // Defaults to AdSize.banner
    BannerAdWidget(), 
  ],
)
```

You can also specify a custom size:

```dart
BannerAdWidget(size: AdSize.mediumRectangle)
```

### Showing Interstitial Ads

Interstitial ads are preloaded automatically after initialization. Call `showInterstitialAd()` when you want to display one (e.g., between screen transitions).

```dart
AdService.instance.showInterstitialAd();
```

### Showing Rewarded Ads

Rewarded ads are also preloaded. Provide a callback to handle the reward.

```dart
AdService.instance.showRewardedAd(
  onUserEarnedReward: (reward) {
    // Grant reward to user
    print('User earned: ${reward.amount} ${reward.type}');
  },
);
```

## Platform Specific Setup

### Android

Add your AdMob App ID to your `android/app/src/main/AndroidManifest.xml` file by adding a `<meta-data>` tag inside the `<application>` tag:

```xml
<manifest>
    <application>
        <!-- Sample AdMob App ID: ca-app-pub-3940256099942544~3347511713 -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

### iOS

Update your `ios/Runner/Info.plist` file to include the `GADApplicationIdentifier` key with your AdMob App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

Make sure to replace `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy` with your actual AdMob App ID.

