import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';
import 'ads_consent_service.dart';
import 'ads_service.dart';

/// Fixed phone banner (320×50) for the shell footer.
///
/// Never uses adaptive / anchored adaptive sizes. Hides on load failure.
/// Does not crop, scale, or transform the ad view.
class FooterBannerAd extends StatefulWidget {
  const FooterBannerAd({
    super.key,
    this.adUnitId,
    this.onVisibilityChanged,
    @visibleForTesting this.createBanner,
  });

  final String? adUnitId;

  /// Fires when the banner becomes visible or collapses after failure/dispose.
  final ValueChanged<bool>? onVisibilityChanged;

  /// Test seam — returns a [BannerAd] without touching the network.
  final BannerAd Function({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  })? createBanner;

  /// Fixed phone banner width in logical pixels.
  static const double bannerWidth = 320;

  /// Fixed phone banner height in logical pixels ([AdSize.banner]).
  static const double bannerHeight = 50;

  /// No decorative vertical padding.
  static const double stripVerticalPadding = 0;

  /// Height reserved when the banner is visible.
  static const double reservedStripHeight = bannerHeight;

  /// Forced AdMob size — standard banner only (never adaptive / fullBanner).
  static const AdSize fixedPhoneBanner = AdSize(
    width: 320,
    height: 50,
  );

  @override
  State<FooterBannerAd> createState() => _FooterBannerAdState();
}

class _FooterBannerAdState extends State<FooterBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    assert(
      FooterBannerAd.fixedPhoneBanner.width == AdSize.banner.width &&
          FooterBannerAd.fixedPhoneBanner.height == AdSize.banner.height,
      'fixedPhoneBanner must match AdSize.banner (320×50)',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    if (kIsWeb) {
      if (mounted) setState(() => _failed = true);
      _notifyVisible(false);
      return;
    }

    if (!AdsConsentService.canRequestAds || !AdsService.isInitialized) {
      if (mounted) setState(() => _failed = true);
      _notifyVisible(false);
      return;
    }

    try {
      // FIXED 320×50 only — never adaptive / anchored / fullBanner / large.
      const size = FooterBannerAd.fixedPhoneBanner;

      final unitId = widget.adUnitId ?? AdsConfig.bannerAdUnitId;
      final banner = widget.createBanner?.call(
            adUnitId: unitId,
            size: size,
            listener: _listener(),
          ) ??
          BannerAd(
            adUnitId: unitId,
            size: size,
            request: const AdRequest(),
            listener: _listener(),
          );

      await banner.load();
      if (!mounted) {
        banner.dispose();
        return;
      }

      // Reject unexpected sizes (e.g. fullBanner 468×60) instead of stretching.
      if (banner.size.width != FooterBannerAd.bannerWidth ||
          banner.size.height != FooterBannerAd.bannerHeight) {
        debugPrint(
          'FooterBannerAd: rejecting unexpected size '
          '${banner.size.width}x${banner.size.height} '
          '(expected ${FooterBannerAd.bannerWidth}x${FooterBannerAd.bannerHeight})',
        );
        banner.dispose();
        if (mounted) setState(() => _failed = true);
        _notifyVisible(false);
        return;
      }

      setState(() => _banner = banner);
    } catch (error, stackTrace) {
      debugPrint('FooterBannerAd load failed: $error');
      debugPrint('$stackTrace');
      if (mounted) setState(() => _failed = true);
      _notifyVisible(false);
    }
  }

  BannerAdListener _listener() {
    return BannerAdListener(
      onAdLoaded: (ad) {
        if (!mounted) return;
        if (ad is BannerAd &&
            (ad.size.width != FooterBannerAd.bannerWidth ||
                ad.size.height != FooterBannerAd.bannerHeight)) {
          debugPrint(
            'FooterBannerAd: onAdLoaded unexpected size '
            '${ad.size.width}x${ad.size.height}',
          );
          ad.dispose();
          setState(() {
            _banner = null;
            _loaded = false;
            _failed = true;
          });
          _notifyVisible(false);
          return;
        }
        setState(() => _loaded = true);
        _notifyVisible(true);
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('FooterBannerAd failed: $error');
        ad.dispose();
        if (!mounted) return;
        setState(() {
          _banner = null;
          _loaded = false;
          _failed = true;
        });
        _notifyVisible(false);
      },
    );
  }

  void _notifyVisible(bool visible) {
    widget.onVisibilityChanged?.call(visible);
  }

  @override
  void dispose() {
    _banner?.dispose();
    widget.onVisibilityChanged?.call(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !_loaded || _banner == null) {
      return const SizedBox.shrink();
    }

    // Fixed 320×50 box only — centered, not stretched to full width.
    return SizedBox(
      height: FooterBannerAd.bannerHeight,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: FooterBannerAd.bannerWidth,
          height: FooterBannerAd.bannerHeight,
          child: AdWidget(ad: _banner!),
        ),
      ),
    );
  }
}
