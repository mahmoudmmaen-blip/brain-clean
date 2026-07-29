import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens https / mailto URIs via a small platform channel (no extra packages).
class ExternalLinkService {
  ExternalLinkService({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.brainclean.mobile/external_links');

  final MethodChannel _channel;

  static const privacyPolicyUrl =
      'https://mahmoudmmaen-blip.github.io/brain-clean/privacy-policy/';
  static const contactEmailUri = 'mailto:brainclean.app@gmail.com';

  Future<bool> openPrivacyPolicy() => openUri(privacyPolicyUrl);

  Future<bool> openContactEmail() => openUri(contactEmailUri);

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
