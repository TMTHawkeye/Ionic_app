require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'SdkLauncherPlugin'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = 'https://example.com'
  s.author = 'Example'
  s.source = { :git => 'https://example.com', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target = '13.0'
  s.dependency 'Capacitor'

  # TODO: add a dependency on the real SDK's CocoaPod, e.g.:
  # s.dependency 'YourSDK', '~> 1.0'
end
