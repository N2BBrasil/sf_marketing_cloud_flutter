# Run this file to regenerate pigeon files
dart run pigeon \
--input pigeons/pigeons.dart \
--dart_out lib/sf_marketing_cloud_api.dart \
--java_package "com.cacianokroth.sf_marketing_cloud_flutter" \
--kotlin_out  android/src/main/kotlin/com/cacianokroth/sf_marketing_cloud/SfMarketingCloud.kt \
--swift_out ios/Classes/SfMarketingCloud.g.swift