//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

/// A type that can make some kind of HTTP URL request
public protocol RequestBuilder {
    /// Creates request
    ///
    /// Request can be any type of HTTP URL request
    ///
    /// - Parameter fileUrl: The local file URL
    /// - Returns: a valid url request
    func makeRequest(for fileUrl: URL) throws -> URLRequest
}
