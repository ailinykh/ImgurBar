//
//  ImageUploader.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

/// A type that performs image file uploading to the remote server
public protocol ImageUploader {
    /// The result of uploading task completion
    typealias Result = Swift.Result<RemoteImage, Error>
    
    /// Uploads file to remote location
    ///
    /// some discussion info
    ///
    /// - Parameters:
    ///     - image: The local image
    ///     - completion: The completion handler that receives the ``Result`` of operation
    func upload(image: LocalImage, completion: @escaping (Result) -> Void)
}
