//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public class ImgurAuthProvider: AuthProvider {
    private let clientId: String
    private let client: AuthClient
    
    public enum Error: Swift.Error {
        case invalidUrlRedirect
        case insufficientParams
    }
    
    public init(clientId: String, client: AuthClient) {
        self.clientId = clientId
        self.client = client
    }
    
    public func authorize(completion: @escaping (Result<Account, Swift.Error>) -> Void) {
        let url = URL(string:"https://api.imgur.com/oauth2/authorize?client_id=\(clientId)&response_type=token")!
        client.open(url: url) { result in
            switch result {
            case .success(let url):
                do {
                    let authData = try ImgurAuthMapper.handle(url: url)
                    completion(.success(authData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}

private final class ImgurAuthMapper {
    static func handle(url: URL) throws -> Account {
        let parts = url.absoluteString.split(separator: "#")
        guard parts.count > 1, let path = parts.last
        else {
            throw ImgurAuthProvider.Error.invalidUrlRedirect
        }
        
        let dict = parse(path: String(path))
        guard let token = dict["access_token"], let account = dict["account_username"] else {
            throw ImgurAuthProvider.Error.insufficientParams
        }
        
        return Account(accessToken: token, accountName: account)
    }
    
    static func parse(path: String) -> [String: String] {
        return path.split(separator: "&")
            .reduce([String:String](), { partialResult, part in
                var partialResult = partialResult
                let parts = part.split(separator: "=")
                if parts.count == 2, let key = parts.first, let value = parts.last {
                    partialResult[String(key)] = String(value)
                }
                return partialResult
            })
    }
}
