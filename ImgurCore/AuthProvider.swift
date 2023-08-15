//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public struct Account: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: TimeInterval
    public let username: String
    
    public init(accessToken: String, refreshToken: String, expiresIn: TimeInterval, username: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.username = username
    }
}

public protocol AuthProvider {
    func authorize(completion: @escaping (Result<Account, Error>) -> Void)
}

public protocol PersistentAuthProvider: AuthProvider {
    func save(account: Account)
    func remove()
}
