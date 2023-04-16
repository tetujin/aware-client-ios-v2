# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'aware-client-ios-v2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for aware-client-ios-v2
  pod 'AWAREFramework', '~> 1.14.5'
  pod 'AWAREFramework/Microphone' , '~> 1.14.5'
  pod 'AWAREFramework/MotionActivity', '~> 1.14.5'
  pod 'AWAREFramework/Bluetooth', '~> 1.14.5'
  pod 'AWAREFramework/Calendar', '~> 1.14.5'
  pod 'AWAREFramework/Contact', '~> 1.14.5'
  pod 'AWAREFramework/HealthKit', '~> 1.14.5'
  
#  pod 'AWAREFramework'               , :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/Microphone'    , :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/MotionActivity', :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/Bluetooth'     , :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/Calendar'      , :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/Contact'       , :path => '../AWAREFramework-iOS'
#  pod 'AWAREFramework/HealthKit'     , :path => '../AWAREFramework-iOS'

#  pod 'Charts', '~> 4.1.0'
#  pod 'Onboard', '~> 2.3.3'
#  pod 'DynamicColor', '~> 5.0.1'
  
  target 'aware-client-ios-v2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'aware-client-ios-v2UITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
