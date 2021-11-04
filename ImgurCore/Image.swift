//
//  Image.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 31.10.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public struct LocalImage {
    let fileUrl: URL
    
    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
}

public struct RemoteImage {
    let url: URL
}
