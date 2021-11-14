//
//  RequestBuilder.swift
//  ImgurCore
//
//  Created by Anton Ilinykh on 14.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public protocol RequestBuilder {
    func makeRequest(for fileUrl: URL) throws -> URLRequest
}
