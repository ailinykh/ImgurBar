//
//  ImageUploader.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

/// A type that performs image file uploading to the remote server
public protocol ImageUploader {
    /// Uploads file to remote location
    ///
    /// some discussion info
    ///
    /// - Parameters:
    ///     - image: The local image
    ///     - completion: The completion handler that provides the ``RemoteImage`` in case of succes and an Error in case of failure
    func upload(image: LocalImage, completion: @escaping (RemoteImage?, Error?) -> Void)
}
