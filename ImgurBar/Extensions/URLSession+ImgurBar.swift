//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

extension URLSession: HTTPClient {
    public func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        if let httpMethod = request.httpMethod, httpMethod == "POST" {
            performUploadTask(for: request, completion: completion)
        } else {
            performDataTask(for: request, completion: completion)
        }
    }
    
    private func performUploadTask(for request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        uploadTask(with: request, from: request.httpBody) { data, response, error in
            guard let data = data, let response = response else {
                let unknown = NSError(domain: "unknown error", code: -1)
                completion(.failure(error ?? unknown))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
    
    private func performDataTask(for request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        dataTask(with: request) { data, response, error in
            guard let data = data, let response = response else {
                let unknown = NSError(domain: "unknown error", code: -1)
                completion(.failure(error ?? unknown))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
}
