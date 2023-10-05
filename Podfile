# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'MonitorizareVot' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # pod 'Alamofire', '5.0.0'
  # pod 'SwiftKeychainWrapper', '3.2.0'
  # pod 'Firebase/Core', '6.31.0'
  # pod 'Firebase/Crashlytics', '6.31.0'
  # pod 'Firebase/Analytics', '6.31.0'
  # pod 'Firebase/Messaging', '6.31.0'
  # pod 'Firebase/RemoteConfig', '6.31.0'
  # pod 'SnapKit', '4.2.0'
  # pod 'ReachabilitySwift', '5.0.0'
  # pod 'Keyboard+LayoutGuide', '1.6.0'
  # pod 'SwiftyMarkdown', '0.6.2'
  # pod 'PromisesSwift', '1.2.10'

  pod 'Alamofire'
  pod 'SwiftKeychainWrapper'
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'SnapKit'
#  pod 'ReachabilitySwift', '5.1.0'
  pod 'Keyboard+LayoutGuide'
  pod 'SwiftyMarkdown'
  pod 'PromisesSwift'

  # Pods for MonitorizareVot

  target 'MonitorizareVotTests' do
    inherit! :search_paths
#    pod 'Alamofire', '5.0.0'
#    pod 'SwiftKeychainWrapper', '3.2.0'
    # Pods for testing
  end

  target 'MonitorizareVotUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# post install
post_install do |installer|
  # fix xcode 15 DT_TOOLCHAIN_DIR - remove after fix oficially - https://github.com/CocoaPods/CocoaPods/issues/12065
  installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
  end
end
