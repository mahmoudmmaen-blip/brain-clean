import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';

/// Adaptive footer banner. Hides itself cleanly when load fails or disposed.
class FooterBannerAd extends StatefulWidget {
  const FooterBannerAd({
    super.key,
    this.adUnitId,
    @visibleForTesting this.createBanner,
  });

  final String? adUnitId;

  /// Test seam — returns a [BannerAd] without touching the network.
  final BannerAd Function({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  })? createBanner;

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
      setState(() => _failed = true);
      return;
    }

    try {
      final width = MediaQuery.sizeOf(context).width.truncate();
      final size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ??
              AdSize.banner;

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
    }
  }

  BannerAdListener _listener() {
    return BannerAdListener(
      onAdLoaded: (ad) {
        if (!mounted) return;
        setState(() => _loaded = true);
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
      },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !_loaded || _banner == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: _banner!.size.width.toDouble(),
          height: _banner!.size.height.toDouble(),
          child: AdWidget(ad: _banner!),
        ),
      ),
    );
  }
}
