//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, URLResponse), Error>
    
    func perform(request: URLRequest, completion: @escaping (Result) -> Void)
}
