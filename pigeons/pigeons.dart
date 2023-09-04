import 'package:pigeon/pigeon.dart';

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

@HostApi()
abstract class SfMarketingCloudHostApi {
  void initialize(SfMarketingCloudConfig config);

  void setPushToken(String token);

  void setContactKey(String contactKey);

  void enableVerboseLogging();

  void disableVerboseLogging();
}
