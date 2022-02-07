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
    private let keychain = KeychainService(service: "LocalAuthProvider")
    
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
        print(String(data: data, encoding: .utf8) ?? "failed to store account in the keychain")
    }
}

private final class KeychainService {
    let service: String
    
    init(service: String) {
        self.service = service
    }
    
    func data(for key: String) -> Data? {
        let query:[String: AnyObject] = [
            kSecAttrService as String: service as NSString,
            kSecAttrAccount as String: key as NSString,
            kSecClass as String: kSecClassInternetPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
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
        var query:[String: AnyObject] = [
            kSecAttrService as String: service as NSString,
            kSecAttrAccount as String: key as NSString,
            kSecClass as String: kSecClassInternetPassword,
            kSecValueData as String: data as AnyObject
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            print("Item \"\(key)\" already exists")
            query.removeValue(forKey: kSecValueData as String)
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
}
