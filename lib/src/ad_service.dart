import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

/// Service for managing Google Mobile Ads.
/// Supports Banner, Interstitial, and Reward ads.
class AdService {
  AdService._();
  static final AdService _instance = AdService._();
  static AdService get instance => _instance;

  AdConfig? _config;

  // Getters for testing/verification
  AdConfig? get config => _config;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  bool _isRewardedLoading = false;

  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;

  /// Initialize the Mobile Ads SDK with configuration.
  Future<void> initialize(AdConfig config) async {
    _config = config;
    await MobileAds.instance.initialize();

    // Only load ads if showAds is true
    if (config.showAds) {
      loadInterstitialAd();
      loadRewardedAd();
    }
  }

  /// Create and load a banner ad.
  /// Returns the BannerAd instance for usage in a widget.
  BannerAd? createBannerAd({
    required AdSize size,
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (_config?.showAds != true) return null;

    final banner = BannerAd(
      adUnitId: _config!.bannerAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );

    banner.load();
    return banner;
  }

  /// Load an interstitial ad.
  void loadInterstitialAd() {
    if (_config?.showAds != true) return;

    InterstitialAd.load(
      adUnitId: _config!.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _isInterstitialLoaded = false;
                  loadInterstitialAd(); // Preload next
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _isInterstitialLoaded = false;
                  loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the interstitial ad if loaded.
  Future<void> showInterstitialAd() async {
    if (_config?.showAds != true) return;
    if (_isInterstitialLoaded && _interstitialAd != null) {
      await _interstitialAd?.show();
    } else {
      debugPrint('Interstitial ad not ready yet.');
      // Try loading again if it wasn't ready
      loadInterstitialAd();
    }
  }

  /// Load a rewarded ad.
  void loadRewardedAd() {
    if (_config?.showAds != true) return;
    if (_isRewardedLoading || _isRewardedLoaded) return;

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _config!.rewardAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          _isRewardedLoading = false;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the rewarded ad and call onUserEarnedReward when reward is earned.
  Future<void> showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) async {
    if (_config?.showAds != true) return;
    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedLoaded = false;
          onAdDismissed?.call(); // Trigger custom callback
          loadRewardedAd(); // Preload next
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedLoaded = false;
          loadRewardedAd();
        },
      );

      await _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(reward);
        },
      );
    } else {
      debugPrint('Rewarded ad not ready yet.');
      // Try loading again
      loadRewardedAd();
    }
  }

  /// Dispose all ads.
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
