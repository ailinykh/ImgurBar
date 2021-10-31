//
//  ImageUploader.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

protocol ImageUploader {
    func uploadImage(with data: Data, completion: @escaping (Data, Error) -> Void)
}
