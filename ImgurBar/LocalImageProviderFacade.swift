//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

final class LocalImageProviderFacade: LocalImageConsumer {
    let onImage: (LocalImage) -> Void
    
    init(onImage: @escaping (LocalImage) -> Void) {
        self.onImage = onImage
    }
    
    func consume(image localImage: LocalImage) {
        onImage(localImage)
    }
}
