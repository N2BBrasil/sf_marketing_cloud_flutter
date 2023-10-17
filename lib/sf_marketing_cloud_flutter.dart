import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_api.g.dart';

export 'sf_marketing_cloud_api.g.dart'
    show
        SfMarketingCloudConfig,
        SFMCEvent,
        SFMCUserAttribute,
        SFMCConversionData;

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

  @override
  Future<void> setAttribute(SFMCUserAttribute attribute) {
    return _handler(() => _api.setAttribute(attribute));
  }

  @override
  Future<void> setAttributes(List<SFMCUserAttribute?> attributes) {
    return _handler(() => _api.setAttributes(attributes));
  }

  @override
  Future<void> trackEvent(SFMCEvent event) {
    return _handler(() => _api.trackEvent(event));
  }

  @override
  Future<void> addTags(List<String?> tags) {
    return _handler(() => _api.addTags(tags));
  }

  @override
  Future<void> clearAttributes(List<String?> attributeKeys) {
    return _handler(() => _api.clearAttributes(attributeKeys));
  }

  @override
  Future<void> removeTags(List<String?> tags) {
    return _handler(() => _api.removeTags(tags));
  }

  @override
  Future<void> trackConversion(SFMCConversionData data) {
    return _handler(() => _api.trackConversion(data));
  }

  @override
  Future<void> trackPageView(String path) {
    return _handler(() => _api.trackPageView(path));
  }
}
