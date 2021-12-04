//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

extension URLSession: HTTPClient {
    public func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        uploadTask(with: request, from: request.httpBody) { data, response, error in
            guard let data = data, let response = response else {
                completion(.failure(error ?? NSError(domain: "unknown error", code: 0)))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
}
