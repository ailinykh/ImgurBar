//
//  ImageUploader.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

/// A type that performs image file uploading to the remote server
public protocol ImageUploader {
    /// The result of uploading task completion
    typealias Result = Swift.Result<URL, Error>
    
    /// Uploads file to remote location
    ///
    /// some discussion info
    ///
    /// - Parameters:
    ///     - from: The local image URL
    ///     - completion: The completion handler that receives the ``Result`` of operation
    func upload(url: URL, completion: @escaping (Result) -> Void)
}
