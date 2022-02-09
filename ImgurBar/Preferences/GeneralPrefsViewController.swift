//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa

@objc
class AccountViewModel: NSObject {
    @objc var authorized = false
    @objc var name = "Not authorized"
    
    var onLogin = {}
    var onLogout = {}
}

class GeneralPrefsViewController: NSViewController {
    
    var onLaunchOnSystemStartupChanged: (Bool) -> Void = { _ in }
    var onUploadScreenshotsChanged: (Bool) -> Void = { _ in }
    
    @objc dynamic var launchOnSystemStartup = false {
        didSet {
            onLaunchOnSystemStartupChanged(launchOnSystemStartup)
        }
    }
    
    @objc dynamic var uploadScreenshots = false {
        didSet {
            onUploadScreenshotsChanged(uploadScreenshots)
        }
    }
    
    @objc dynamic var accountViewModel: AccountViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func display(_ model: AccountViewModel) {
        accountViewModel = model
    }
    
    @IBAction func loginButtonAction(_ sender: AnyObject?) {
        accountViewModel?.onLogin()
    }
    
    @IBAction func logoutButtonAction(_ sender: AnyObject?) {
        accountViewModel?.onLogout()
    }
}
