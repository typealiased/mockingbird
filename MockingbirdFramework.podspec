Pod::Spec.new do |s|
  s.name                   = 'MockingbirdFramework'
  s.module_name            = 'Mockingbird'
  s.version                = `make get-version`
  s.summary                = 'A convenient mocking framework for Swift.'
  s.homepage               = `make get-repo-url`
  s.license                = { :type => 'MIT', :file => 'LICENSE' }
  s.author                 = { 'Andrew Chang' => 'andrew.chang@bird.co' }
  s.source                 = { :git => s.homepage + '.git', :tag => s.version }
  s.source_files           = 'Sources/MockingbirdFramework/**/*.swift'
  s.prepare_command        = 'make download'
  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.14'
  s.tvos.deployment_target = '9.0'
  s.frameworks             = 'XCTest'
  s.user_target_xcconfig   = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  s.pod_target_xcconfig    = { 'ENABLE_BITCODE' => 'NO' }
  s.swift_version          = '5.0'
  s.preserve_paths         = 'README.md', 'LICENSE', 'Makefile', 'mockingbird', 'Codesigning/*', 'Sources/MockingbirdCli/Info.plist'
end
