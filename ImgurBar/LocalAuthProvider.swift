//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

private extension String {
    static let account = "account"
}

final class LocalAuthProvider: PersistentAuthProvider {
    private let storage: StorageService
    
    init(storage: StorageService) {
        self.storage = storage
    }
    
    func authorize(completion: @escaping (Result<Account, Error>) -> Void) {
        guard let data = storage.get(for: .account), let account = try? JSONDecoder().decode(Account.self, from: data) else {
            let error = NSError(domain: "not found", code: -1)
            completion(.failure(error))
            return
        }
        
        completion(.success(account))
    }
    
    func save(account: Account) {
        let data = try! JSONEncoder().encode(account)
        storage.set(data: data, for: .account)
    }
    
    func remove() {
        storage.delete(for: .account)
    }
}
