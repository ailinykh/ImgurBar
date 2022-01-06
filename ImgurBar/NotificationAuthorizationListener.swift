//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Cocoa

class NotificationAuthorizationListener: NSObject {
    @objc dynamic var isAuthorized = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: .authorizationStatusChanged, object: nil, queue: nil) { [weak self] note in
            guard let authorized = note.object as? Bool else {
                print("expected `note.object` as boolean", note)
                return
            }
            
            self?.isAuthorized = authorized
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
