//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

class ScreenshotObserver: NSObject {
    private lazy var query: NSMetadataQuery = {
        let query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        query.searchScopes = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        return query
    }()
    
    var onURL: (URL) -> Void = { _ in }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidUpdate, object: query, queue: nil) { [weak self] note in
            guard
                let items = note.userInfo?[kMDQueryUpdateChangedItems] as? [NSMetadataItem],
                let last = items.last,
                let path = last.value(forAttribute: kMDItemPath as String) as? String
            else { return }
            self?.onURL(URL(fileURLWithPath: path))
        }
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func start() {
        query.start()
    }
    
    func stop() {
        query.stop()
    }
}
