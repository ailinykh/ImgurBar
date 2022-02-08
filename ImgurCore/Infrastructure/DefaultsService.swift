//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public final class DefaultsService: StorageService {
    private let defaults = UserDefaults.standard
    
    public init() {}
    
    public func get(for key: String) -> Data? {
        defaults.data(forKey: key)
    }
    
    public func set(data: Data, for key: String) {
        defaults.set(data, forKey: key)
    }
    
    public func delete(for key: String) {
        defaults.removeObject(forKey: key)
    }
}
