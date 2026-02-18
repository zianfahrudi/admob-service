/// Configuration for AdMob Service
class AdConfig {
  /// Whether to show ads in the application
  final bool showAds;

  /// Ad Unit ID for Banner Ads
  final String bannerAdId;

  /// Ad Unit ID for Interstitial Ads
  final String interstitialAdId;

  /// Ad Unit ID for Rewarded Ads
  final String rewardAdId;

  const AdConfig({
    this.showAds = true,
    required this.bannerAdId,
    required this.interstitialAdId,
    required this.rewardAdId,
  });
}
