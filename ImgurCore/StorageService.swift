//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public protocol StorageService {
    func get(for key: String) -> Data?
    func set(data: Data, for key: String)
    func delete(for key: String)
}
