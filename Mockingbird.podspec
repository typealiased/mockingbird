Pod::Spec.new do |s|
  s.name                   = 'Mockingbird'
  s.version                = '0.1.0'
  s.summary                = 'A convenient mocking framework for Swift.'
  s.homepage               = 'https://github.com/birdrides/mockingbird'
  s.license                = { :type => 'MIT', :file => 'LICENSE' }
  s.author                 = { 'Andrew Chang' => 'andrew.chang@bird.co', 'Bird Rides, Inc.' => 'hello@bird.co' }
  s.source                 = { :git => 'https://github.com/birdrides/mockingbird.git', :tag => s.version.to_s }
  s.source_files           = 'MockingbirdFramework/**/*.swift', 'MockingbirdShared/**/*.swift'
  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.9'
  s.tvos.deployment_target = '9.0'
  s.frameworks             = 'XCTest', 'Foundation'
  s.requires_arc           = true
  s.pod_target_xcconfig    = { 'ENABLE_BITCODE' => 'NO' }
  s.swift_version          = '5.0'
end
