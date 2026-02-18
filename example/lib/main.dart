import 'package:flutter/material.dart';
import 'package:admob_service/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdService with test configuration
  await AdService.instance.initialize(
    const AdConfig(
      showAds: true,
      bannerAdId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad ID
      interstitialAdId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad ID
      rewardAdId: 'ca-app-pub-3940256099942544/5224354917', // Test Ad ID
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Admob Service Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Banner Ad below:'),
              const SizedBox(height: 20),
              // Use the BannerAdWidget
              const BannerAdWidget(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  AdService.instance.showInterstitialAd();
                },
                child: const Text('Show Interstitial Ad'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AdService.instance.showRewardedAd(
                    onUserEarnedReward: (reward) {
                      debugPrint(
                        'User earned reward: ${reward.amount} ${reward.type}',
                      );
                    },
                  );
                },
                child: const Text('Show Rewarded Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
