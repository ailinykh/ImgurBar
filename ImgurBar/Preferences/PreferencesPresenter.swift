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
            
            let model = AccountViewModel()
            model.onLogin = { [weak self] in
                self?.authProvider.authorize { result in
                    switch result {
                    case .success(let data):
                        print("Got token:", data.token)
                        let model = AccountViewModel()
                        model.onLogout = { print("logout") }
                        model.name = data.username
                        model.authorized = true
                        vc.display(model)
                    case .failure(let error):
                        print("Auth failed", error)
                    }
                }
            }
            vc.display(model)
        }
        
        return windowController
    }
}
