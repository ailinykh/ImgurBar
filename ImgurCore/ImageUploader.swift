//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

/// A type that performs image file uploading to the remote server
public protocol ImageUploader {
    /// The result of uploading task completion
    typealias Result = Swift.Result<RemoteImage, Error>
    
    /// Uploads file to remote location
    ///
    /// some discussion info
    ///
    /// - Parameters:
    ///     - from: The local image URL
    ///     - completion: The completion handler that receives the ``Result`` of operation
    func upload(_ localImage: LocalImage, completion: @escaping (Result) -> Void)
}
