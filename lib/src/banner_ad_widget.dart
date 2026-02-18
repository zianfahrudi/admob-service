import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// A widget that displays a Banner Ad.
class BannerAdWidget extends StatefulWidget {
  final AdSize size;

  const BannerAdWidget({super.key, this.size = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (AdService.instance.config?.showAds ?? false) {
      _bannerAd = AdService.instance.createBannerAd(
        size: widget.size,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
          ad.dispose();
          _bannerAd = null;
          debugPrint('BannerAd failed to load: $error');
        },
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return empty sized box if ad is not loaded or disabled
    return const SizedBox.shrink();
  }
}
