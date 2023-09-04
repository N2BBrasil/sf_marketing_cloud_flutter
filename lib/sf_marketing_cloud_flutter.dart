import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_api.dart';

export 'sf_marketing_cloud_api.dart' show SfMarketingCloudConfig;

class SfMarketingCloud implements SfMarketingCloudHostApi {
  final _api = SfMarketingCloudHostApi();
  bool initialized = false;

  @override
  Future<void> disableVerboseLogging() => _api.disableVerboseLogging();

  @override
  Future<void> enableVerboseLogging() => _api.enableVerboseLogging();

  @override
  Future<void> initialize(SfMarketingCloudConfig config) async {
    try {
      await _api.initialize(config);
      initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setContactKey(String contactKey) {
    return _handler(() => _api.setContactKey(contactKey));
  }

  @override
  Future<void> setPushToken(String token) {
    return _handler(() => _api.setPushToken(token));
  }

  Future<void> _handler(Function() fn) async {
    if (!initialized) {
      throw Exception('SfMarketingCloud is not initialized');
    }
    try {
      await fn();
    } catch (e) {
      rethrow;
    }
  }
}
