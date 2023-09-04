import 'package:flutter_test/flutter_test.dart';
import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_flutter.dart';
import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_flutter_platform_interface.dart';
import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSfMarketingCloudFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SfMarketingCloudFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SfMarketingCloudFlutterPlatform initialPlatform = SfMarketingCloudFlutterPlatform.instance;

  test('$MethodChannelSfMarketingCloudFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSfMarketingCloudFlutter>());
  });

  test('getPlatformVersion', () async {
    SfMarketingCloudFlutter sfMarketingCloudFlutterPlugin = SfMarketingCloudFlutter();
    MockSfMarketingCloudFlutterPlatform fakePlatform = MockSfMarketingCloudFlutterPlatform();
    SfMarketingCloudFlutterPlatform.instance = fakePlatform;

    expect(await sfMarketingCloudFlutterPlugin.getPlatformVersion(), '42');
  });
}
