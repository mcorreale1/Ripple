source 'https://bitbucket.org/omegarinc/cocoapods-specs.git' # private spec repo
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "9.0"
use_frameworks!

target 'Ripple' do
#    pod 'Bolts', '1.7.0'
    pod ‘Backendless’
    pod 'CVCalendar', '~> 1.3.1'
	pod 'FBSDKCoreKit', '~> 4.15'
    pod 'FBSDKLoginKit', '~> 4.15'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'commoncode-ios'
    pod 'JTCalendar', '~> 2.0'
    pod 'Firebase/Storage'
    pod 'Firebase/AdMob'
    pod 'Firebase/Auth'
    pod 'Firebase/Crash'
    pod 'Firebase/Database'
    pod 'Firebase/RemoteConfig'
    pod 'MagicalRecord'
    pod 'ORCommonCode-Swift', '0.7.0'
    pod 'ORCommonUI-Swift', ‘1.0.0’ 
    pod 'ORCropImageController'
    pod 'ORLocalizationSystem'
    pod 'UITextView+Placeholder', '~> 1.2'
    platform :ios, '8.0'
    use_frameworks!
    pod 'SDWebImage', '~>3.8'
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'  ## or '3.0'
        end
    end
end

end
