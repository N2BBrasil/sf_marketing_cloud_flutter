#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sf_marketing_cloud_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sf_marketing_cloud_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Sales Force Marketing Cloud plugin.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/cacianokroth'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Caciano Kroth' => 'caciano.kroths@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0', '8.0.13'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'MarketingCloudSDK'
end
