Pod::Spec.new do |s|
  s.name                        = 'MockingbirdFramework'
  s.module_name                 = 'Mockingbird'
  s.version                     = `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Sources/MockingbirdFramework/Info.plist`
  s.summary                     = 'A Swifty mocking framework for Swift and Objective-C.'
  s.homepage                    = 'https://github.com/birdrides/mockingbird'
  s.license                     = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author                      = { 'Andrew Chang' => 'typealiased@gmail.com' }
  s.source                      = { :git => s.homepage + '.git', :tag => s.version }
  s.ios.deployment_target       = '9.0'
  s.osx.deployment_target       = '10.10'
  s.tvos.deployment_target      = '9.0'
  s.watchos.deployment_target   = '7.4'
  s.swift_version               = '5.0'
  s.frameworks                  = 'XCTest'
  
  s.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks',
  }
  
  s.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'ENABLE_TESTABILITY' => 'YES',
    'COPY_PHASE_STRIP' => 'NO',
    'DEFINES_MODULE' => 'YES',
  }

  s.source_files = [
    'Sources/MockingbirdFramework/**/*.{swift,h,m,mm}',
    'Sources/MockingbirdCommon/**/*.swift',
  ]

  s.preserve_paths = [
    'README.md',
    'LICENSE.md',
    'mockingbird',
    'Sources/MockingbirdAutomationCli/Resources/CodesigningRequirements/*',
    'Sources/MockingbirdFramework/Info.plist',
    'Sources/MockingbirdCli/Info.plist',
  ]
end
