import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSfMarketingCloudFlutter platform = MethodChannelSfMarketingCloudFlutter();
  const MethodChannel channel = MethodChannel('sf_marketing_cloud_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
