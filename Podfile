source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
inhibit_all_warnings!

target 'e-Hentai' do
    xcodeproj 'e-Hentai'

    pod 'ViewDeck', '~> 2.3.1'
    pod 'SDWebImage', '~> 3.6'
    pod 'ReactiveCocoa', '~> 2.3.1'
    pod 'SupportKit', '~> 2.4.0'
    pod 'ChameleonFramework', '~> 2.0.4'
    pod 'Realm', '~> 0.96.0'
    pod 'SVProgressHUD', '~> 1.1.2'
    pod 'MWPhotoBrowser', '~> 2.1.1'
    pod 'QuickDialog', '~> 1.0'
    pod 'FXBlurView', '~> 1.6.3'
    pod 'JDStatusBarNotification', '~> 1.5.2'

    target 'HentaiTest' do
        inherit! :search_paths
        pod 'KIF', '~> 3.0', :configurations => ['Debug']
    end
end
