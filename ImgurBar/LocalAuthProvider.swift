//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

final class LocalAuthProvider: AuthProvider {
    private let keychain = KeychainService(service: "LocalAuthProvider")
    
    public enum Error: Swift.Error {
        case notFound
    }
    
    func authorize(completion: @escaping (Result<Account, Swift.Error>) -> Void) {
        guard let data = keychain.data(for: "Account"), let account = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LocalAccount.self, from: data) else {
            completion(.failure(Error.notFound))
            return
        }
        
        completion(.success(Account(token: account.token, username: account.username)))
    }
    
    func save(account: Account) {
        let localAccount = LocalAccount()
        localAccount.token = account.token
        localAccount.username = account.username
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: localAccount, requiringSecureCoding: false) else {
            print("Failed to archive account", account)
            return
        }
        keychain.set(data: data, for: "Account")
    }
}

@objc(IBLocalAccount)
private final class LocalAccount: NSObject, NSCoding {
    var token: String = ""
    var username: String = ""
    
    func encode(with coder: NSCoder) {
        coder.encode(token, forKey: "token")
        coder.encode(username, forKey: "username")
    }
    
    override init() {}
    
    init?(coder: NSCoder) {
        guard let token = coder.decodeObject(of: NSString.self, forKey: "token"), let username = coder.decodeObject(of: NSString.self, forKey: "account") else {
            print("local account decoding failed")
            return
        }
        self.token = token as String
        self.username = username as String
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
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("SecItemCopyMatching failed", status)
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
            kSecClass as String: kSecClassIdentity,
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
            print("SecItemAdd/SecItemUpdate failed:", status)
        }
    }
}
