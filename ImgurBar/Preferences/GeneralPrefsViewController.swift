//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa

class GeneralPrefsViewController: NSViewController {
    
    var onLaunchOnSystemStartupChanged: (Bool) -> Void = { _ in }
    
    
    @objc dynamic var launchOnSystemStartup = false {
        didSet {
            onLaunchOnSystemStartupChanged(launchOnSystemStartup)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
