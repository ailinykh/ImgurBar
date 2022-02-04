//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

public struct Account {
    public let token: String
    public let username: String
    
    public init(token: String, username: String) {
        self.token = token
        self.username = username
    }
}

public protocol AuthProvider {
    func authorize(completion: @escaping (Result<Account, Error>) -> Void)
}
