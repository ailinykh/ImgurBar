//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
