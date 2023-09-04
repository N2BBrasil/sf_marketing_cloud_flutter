import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sf_marketing_cloud_flutter/sf_marketing_cloud_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _sfMarketingCloudFlutterPlugin = SfMarketingCloud();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _sfMarketingCloudFlutterPlugin.enableVerboseLogging();
    // _sfMarketingCloudFlutterPlugin.initialize(
    //   SfMarketingCloudConfig(
    //     appId: 'df86f5e7-8429-4440-aec6-433528ff4cd5',
    //     accessToken: 'anUXpGCK7XS1c7stu3MDgFtj',
    //     appEndpoint:
    //         'https://mcztx763gcky9vn2thhbc1h1p16m.device.marketingcloudapis.com/',
    //     mid: '514004931',
    //     senderId: '797050328040',
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
