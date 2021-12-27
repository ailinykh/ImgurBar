//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import ImgurCore
import AppKit

final class LegacyAuthClient: AuthClient {
    
    private var pendingCompletion: ((Result<URL, Error>) -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(forName: .applicationOpenUrl, object: nil, queue: nil) { [weak self] note in
            guard let url = note.object as? URL else {
                let error = NSError(domain: "unexpected", code: 0)
                self?.pendingCompletion?(.failure(error))
                return
            }
            self?.pendingCompletion?(.success(url))
        }
    }
    
    func open(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        pendingCompletion = completion
        NSWorkspace.shared.open(url)
    }
}
