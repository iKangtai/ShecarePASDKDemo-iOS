platform :ios, '9.0'

target 'ShecarePASDKDemo' do
    pod 'Masonry'
end

target 'ShecarePASDKDemoTests' do
    pod 'Masonry'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
  if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
   end
  end
 end
end
