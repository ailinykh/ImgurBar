//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public final class KeychainService: StorageService {
    
    public init() {}
    
    public func get(for key: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil)
            print("SecItemCopyMatching failed", status, message ?? "nil")
            return nil
        }
        
        guard let data = item as? Data else {
            print("SecItem to Data transform failed")
            return nil
        }
        
        return data
    }
    
    public func set(data: Data, for key: String) {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: kSecAttrAccessibleAlways,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            print("Item \"\(key)\" already exists")
            query.removeValue(forKey: kSecValueData)
            let attributes:[String: AnyObject] = [
                kSecValueData as String: data as AnyObject
            ]
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
        
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil)
            print("SecItemAdd failed:", status, message ?? "nil")
        }
    }
    
    public func delete(for key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: kSecAttrAccessibleAlways,
            kSecAttrAccount: key,
            kSecReturnData: true
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil)
            print("SecItemDelete failed:", status, message ?? "nil")
        }
    }
}
