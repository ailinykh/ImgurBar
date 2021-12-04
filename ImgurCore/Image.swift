//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public struct LocalImage {
    public let fileUrl: URL
    
    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
}

public struct RemoteImage {
    public let url: URL
}
