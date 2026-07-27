import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';

/// Compact standard banner (~320×50) in the shell footer.
///
/// Hides cleanly on load failure. Does not crop or scale the ad.
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

  /// Official AdMob standard banner height ([AdSize.banner] ≈ 320×50).
  static const double bannerHeight = 50;

  /// No decorative vertical padding — strip height matches the ad.
  static const double stripVerticalPadding = 0;

  /// Height reserved when the banner is visible (ad only).
  static const double reservedStripHeight = bannerHeight;

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

    try {
      // Official compact banner (~320×50). Do not use tall adaptive sizes.
      const size = AdSize.banner;

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

    // Exact ad size only — no decorative padding block.
    return SizedBox(
      height: FooterBannerAd.bannerHeight,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: _banner!.size.width.toDouble(),
          height: _banner!.size.height.toDouble(),
          child: AdWidget(ad: _banner!),
        ),
      ),
    );
  }
}
