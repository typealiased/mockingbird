Pod::Spec.new do |s|
  s.name                   = 'MockingbirdShared'
  s.version                = '0.1.0'
  s.summary                = 'A convenient mocking framework for Swift.'
  s.homepage               = 'https://github.com/birdrides/mockingbird'
  s.license                = { :type => 'MIT', :file => 'LICENSE' }
  s.author                 = { 'Andrew Chang' => 'andrew.chang@bird.co' }
  # s.source                 = { :git => s.homepage + '.git', :tag => s.version }
  s.source                 = { :git => 'git@github.com:birdrides/mockingbird.git', :tag => s.version }
  s.source_files           = 'MockingbirdShared/**/*.swift'
  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.9'
  s.tvos.deployment_target = '9.0'
  s.frameworks             = 'Foundation'
  s.swift_version          = '5.0'
  s.preserve_paths         = '*'
end
