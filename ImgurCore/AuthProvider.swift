//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

public struct AuthData {
    let accessToken: String
    let accountName: String
}

public protocol AuthProvider {
    func authorize(completion: @escaping (Result<AuthData, Error>) -> Void)
}
