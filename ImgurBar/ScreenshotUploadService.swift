//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

final class ScreenshotUploadService {
    private let observer = ScreenshotObserver()
    
    init(onURL: @escaping (URL) -> Void) {
        observer.onURL = onURL
        if get() {
            observer.start()
        }
    }
    
    func get() -> Bool {
        return UserDefaults.standard.bool(forKey: .uploadSreenshotsAutomatically)
    }
    
    func set(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: .uploadSreenshotsAutomatically)
        if enabled {
            observer.start()
        } else {
            observer.stop()
        }
    }
}
