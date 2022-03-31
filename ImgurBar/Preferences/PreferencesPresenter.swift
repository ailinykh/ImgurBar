//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import AppKit
import ImgurCore

final class PreferencesPresenter {
    
    let localAuthProvider: PersistentAuthProvider
    let remoteAuthProvider: AuthProvider
    let screenshotService: ScreenshotUploadService
    
    init(localAuthProvider: PersistentAuthProvider, remoteAuthProvider: AuthProvider, screenshotService: ScreenshotUploadService) {
        self.localAuthProvider = localAuthProvider
        self.remoteAuthProvider = remoteAuthProvider
        self.screenshotService = screenshotService
    }
    
    func makeController() -> PreferencesWindowController {
        let storyboard = NSStoryboard(name: "Preferences", bundle: .main)
        let windowController = storyboard.instantiateInitialController() as! PreferencesWindowController
        
        if let tab = windowController.window?.contentViewController as? PreferencesTabViewController,
           let vc = tab.tabViewItems.first?.viewController as? GeneralPrefsViewController {
            
            let startupService = LaunchOnSystemStartupService()
            vc.launchOnSystemStartup = startupService.get()
            vc.onLaunchOnSystemStartupChanged = startupService.set
            
            vc.uploadScreenshots = screenshotService.get()
            vc.onUploadScreenshotsChanged = screenshotService.set
            
            localAuthProvider.authorize { [weak self] result in
                switch result {
                case .success(let account):
                    self?.handle(account: account, viewController: vc)
                case .failure:
                    let accountViewModel = AccountViewModel()
                    accountViewModel.onLogin = {
                        self?.remoteAuthProvider.authorize { result in
                            switch result {
                            case .success(let account):
                                print("Got token:", account.token)
                                self?.localAuthProvider.save(account: account)
                                self?.handle(account: account, viewController: vc)
                            case .failure(let error):
                                print("Auth failed", error)
                            }
                        }
                    }
                    vc.display(accountViewModel)
                }
            }
        }
        
        return windowController
    }
    
    private func handle(account: Account, viewController: GeneralPrefsViewController) {
        let accountViewModel = AccountViewModel()
        accountViewModel.onLogout = { [weak self] in
            print("logout")
            self?.localAuthProvider.remove()
        }
        accountViewModel.name = account.username
        accountViewModel.authorized = true
        viewController.display(accountViewModel)
    }
}
