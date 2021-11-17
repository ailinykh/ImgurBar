//
//  LocalImageProvider.swift
//  ImgurCore
//
//  Created by Anton Ilinykh on 15.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public protocol LocalImageConsumer {
    func consume(image localImage: LocalImage)
}

public protocol LocalImageProvider {
    func add(consumer: LocalImageConsumer)
}
