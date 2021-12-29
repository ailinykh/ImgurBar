//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

public struct AuthData {
    public let accessToken: String
    public let accountName: String
    
    public init(accessToken: String, accountName: String) {
        self.accessToken = accessToken
        self.accountName = accountName
    }
}

public protocol AuthProvider {
    func authorize(completion: @escaping (Result<AuthData, Error>) -> Void)
}
