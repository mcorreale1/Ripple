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
    pod 'commoncode-ios', :git => 'https://github.com/mcorreale1/commoncode-ios.git'
    pod 'JTCalendar', '~> 2.0'
    pod 'MagicalRecord'
    pod 'ORCommonCode-Swift', :git => 'https://jettiapps@bitbucket.org/omegarinc/orcommoncode-swift.git'
    pod 'ORCommonUI-Swift', :git => 'https://jettiapps@bitbucket.org/omegarinc/orcommonui-swift.git'
    pod 'ORCropImageController', :git => 'https://jettiapps@bitbucket.org/omegarinc/orcropimagecontroller.git'
    pod 'ORLocalizationSystem', :git => 'https://jettiapps@bitbucket.org/omegarinc/orlocalizationsystem.git'
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
