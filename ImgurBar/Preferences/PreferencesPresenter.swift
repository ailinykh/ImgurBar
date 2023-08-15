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
        let tab = windowController.window?.contentViewController as! PreferencesTabViewController
        let vc = tab.tabViewItems.first?.viewController as! GeneralPrefsViewController
        
        let startupService = LaunchOnSystemStartupService()
        vc.launchOnSystemStartup = startupService.get()
        vc.onLaunchOnSystemStartupChanged = startupService.set
        
        vc.uploadScreenshots = screenshotService.get()
        vc.onUploadScreenshotsChanged = screenshotService.set
        
        vc.display(makeModel(viewController: vc))
        return windowController
    }
    
    private func handle(account: Account, viewController: GeneralPrefsViewController?) {
        let model = makeModel(
            viewController: viewController,
            name: account.username,
            authorized: true)
        viewController?.display(model)
    }
    
    private func makeModel(viewController: GeneralPrefsViewController?, name: String = "", authorized: Bool = false) -> AccountViewModel {
        let accountViewModel = AccountViewModel()
        accountViewModel.onLogout = { [weak self] in
            print("logout")
            self?.localAuthProvider.remove()
            NotificationCenter.default.post(
                name: .userAuthorizationStatusChanged,
                object: nil)
        }
        accountViewModel.onLogin = { [weak self, weak viewController] in
            self?.remoteAuthProvider.authorize { result in
                switch result {
                case .success(let account):
                    print("Got account:", account)
                    self?.localAuthProvider.save(account: account)
                    self?.handle(account: account, viewController: viewController)
                    NotificationCenter.default.post(
                        name: .userAuthorizationStatusChanged,
                        object: account)
                case .failure(let error):
                    print("Auth failed", error)
                }
            }
        }
        accountViewModel.onViewDidAppear = { [weak self, weak viewController] in
            self?.localAuthProvider.authorize { result in
                if let account = try? result.get() {
                    self?.handle(account: account, viewController: viewController)
                }
            }
        }
        accountViewModel.name = name
        accountViewModel.authorized = authorized
        return accountViewModel
    }
}
