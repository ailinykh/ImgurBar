//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public protocol LocalImageConsumer {
    func consume(image localImage: LocalImage)
}

public protocol LocalImageProvider {
    func add(consumer: LocalImageConsumer)
}
