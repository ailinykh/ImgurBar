//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

private extension String {
    static let account = "account"
}

private struct AccountData: Codable {
    let token: String
    let username: String
}

final class LocalAuthProvider: AuthProvider {
    private let keychain = KeychainService()
    
    func authorize(completion: @escaping (Result<Account, Error>) -> Void) {
        guard let data = keychain.data(for: .account), let account = try? JSONDecoder().decode(AccountData.self, from: data) else {
            let error = NSError(domain: "not found", code: -1)
            completion(.failure(error))
            return
        }
        
        completion(.success(Account(token: account.token, username: account.username)))
    }
    
    func save(account: Account) {
        let accountData = AccountData(token: account.token, username: account.username)
        let data = try! JSONEncoder().encode(accountData)
        keychain.set(data: data, for: .account)
    }
    
    func delete() {
        keychain.delete(for: .account)
    }
}

private final class KeychainService {
    func data(for key: String) -> Data? {
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
    
    func set(data: Data, for key: String) {
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
    
    func delete(for key: String) {
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
