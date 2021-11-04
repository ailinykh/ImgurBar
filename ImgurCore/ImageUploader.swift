//
//  ImageUploader.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public protocol ImageUploader {
    func upload(image: LocalImage, completion: @escaping (RemoteImage?, Error?) -> Void)
}
