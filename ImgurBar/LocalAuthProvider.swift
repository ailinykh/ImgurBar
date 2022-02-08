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
        guard let data = keychain.get(for: .account), let account = try? JSONDecoder().decode(AccountData.self, from: data) else {
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
