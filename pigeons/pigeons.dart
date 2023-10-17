import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/sf_marketing_cloud_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/cacianokroth/sf_marketing_cloud_flutter/SfMarketingCloud.g.kt',
    kotlinOptions: KotlinOptions(errorClassName: 'SfMarketingCloudError'),
    swiftOut: 'ios/Classes/SfMarketingCloud.g.swift',
    swiftOptions: SwiftOptions(),
    // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
    objcOptions: ObjcOptions(prefix: 'SFMC'),
    dartPackageName: 'sf_marketing_cloud_flutter',
  ),
)
// #enddocregion config

class SfMarketingCloudConfig {
  SfMarketingCloudConfig({
    required this.appId,
    required this.accessToken,
    required this.senderId,
    required this.appEndpoint,
    required this.mid,
  });

  final String appId;
  final String accessToken;
  final String senderId;
  final String appEndpoint;
  final String mid;
}

class SFMCUserAttribute {
  final String key;
  final String value;

  SFMCUserAttribute({required this.key, required this.value});
}

class SFMCEvent {
  final String name;
  final Map<String?, Object?>? params;

  SFMCEvent({required this.name, this.params});
}

class SFMCConversionData {
  final String id;
  final String order;
  final String item;
  final int quantity;
  final double value;
  final double shipping;
  final double discount;

  SFMCConversionData({
    required this.id,
    required this.order,
    required this.shipping,
    required this.item,
    required this.value,
    this.quantity = 1,
    this.discount = 0,
  });
}

@HostApi()
abstract class SfMarketingCloudHostApi {
  void initialize(SfMarketingCloudConfig config);

  void setPushToken(String token);

  void setContactKey(String contactKey);

  void trackEvent(SFMCEvent event);

  void setAttribute(SFMCUserAttribute attribute);

  void clearAttributes(List<String> attributeKeys);

  void setAttributes(List<SFMCUserAttribute> attributes);

  void addTags(List<String> tags);

  void removeTags(List<String> tags);

  void enableVerboseLogging();

  void disableVerboseLogging();

  void trackConversion(SFMCConversionData data);

  void trackPageView(String path);
}
