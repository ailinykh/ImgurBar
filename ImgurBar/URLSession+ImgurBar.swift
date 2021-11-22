//
//  URLSession+ImgurBar.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 22.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
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
