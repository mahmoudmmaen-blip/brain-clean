import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';

/// Compact standard banner (~320×50) above bottom navigation.
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

  /// Standard banner height used for layout spacing (AdSize.banner).
  static const double bannerHeight = 50;

  /// Vertical padding around the banner strip (top + bottom combined extras).
  static const double stripVerticalPadding = 8;

  /// Approximate reserved strip height when the banner is visible.
  static const double reservedStripHeight =
      bannerHeight + stripVerticalPadding * 2;

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
      // Compact standard banner (~320×50). Safer than tall adaptive banners.
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

    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: FooterBannerAd.stripVerticalPadding,
        ),
        child: Center(
          child: SizedBox(
            width: _banner!.size.width.toDouble(),
            height: _banner!.size.height.toDouble(),
            child: AdWidget(ad: _banner!),
          ),
        ),
      ),
    );
  }
}
