//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public struct Album: Equatable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
