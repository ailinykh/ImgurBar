//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public protocol AuthClient {
    func `open`(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
}
