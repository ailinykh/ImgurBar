//
//  HTTPClient.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, URLResponse), Error>
    
    func perform(request: URLRequest, completion: @escaping (Result) -> Void)
}
