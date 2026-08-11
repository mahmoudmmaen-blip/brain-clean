import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens https / mailto URIs via a small platform channel (no extra packages).
///
/// Channel matches production Android helper: `com.brainclean.mobile/external_links`.
class ExternalLinkService {
  ExternalLinkService({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.brainclean.mobile/external_links');

  final MethodChannel _channel;

  static const privacyPolicyUrl =
      'https://mahmoudmmaen-blip.github.io/brain-clean/privacy-policy/';
  static const contactEmailUri = 'mailto:brainclean.app@gmail.com';

  /// No Terms URL is configured in-repo. Do not invent one; omit Terms CTAs.
  static const String? termsOfUseUrl = null;

  Future<bool> openPrivacyPolicy() => openUri(privacyPolicyUrl);

  Future<bool> openContactEmail() => openUri(contactEmailUri);

  /// Opens Terms only when [termsOfUseUrl] is configured.
  Future<bool> openTermsOfUse() async {
    final url = termsOfUseUrl;
    if (url == null || url.isEmpty) return false;
    return openUri(url);
  }

  Future<bool> openUri(String uri) async {
    try {
      final opened = await _channel.invokeMethod<bool>('openUri', {'uri': uri});
      return opened ?? false;
    } catch (error, stackTrace) {
      debugPrint('ExternalLinkService.openUri failed: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}

final externalLinkService = ExternalLinkService();
