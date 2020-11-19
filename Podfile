# Uncomment the next line to define a global platform for your project
  platform :ios, '13.1'

target 'TestShareDiary' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TestShareDiary
  pod 'Firebase','6.11.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'FSCalendar'
  pod 'SVProgressHUD','2.2.5'
  pod 'SlideMenuControllerSwift'
  pod 'CLImageEditor/AllTools','0.2.4'
  pod 'CropViewController','2.5.3'
  pod 'DKImagePickerController'
  pod 'CalculateCalendarLogic'
end
swift4 = ['SlideMenuControllerSwift']
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if swift4.include?(target.name)
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
