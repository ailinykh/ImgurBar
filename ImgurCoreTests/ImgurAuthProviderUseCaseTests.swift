//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

class ImgurAuthProvider: AuthProvider {
    
    let clientId: String
    let client: AuthClient
    
    enum ImgurAuthError: Error {
        case invalidUrlRedirect
        case insufficientParams
    }
    
    init(clientId: String, client: AuthClient) {
        self.clientId = clientId
        self.client = client
    }
    
    func authorize(completion: @escaping (Result<AuthData, Error>) -> Void) {
        let url = URL(string:"https://api.imgur.com/oauth2/authorize?client_id=\(clientId)&response_type=token")!
        client.open(url: url) { _ in
            let error = NSError(domain: "unknown", code: 0)
            completion(.failure(error))
        }
    }
}

private final class AuthClientStub: AuthClient {
    func open(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        completion(.success(url))
    }
}

class ImgurAuthProviderUseCaseTests: XCTestCase {

    func test_authorize_deliversAuthResult() {
        let (sut, _) = makeSUT()
        let exp = expectation(description: "Authorization expectation")
        
        sut.authorize { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> (ImgurAuthProvider, AuthClientStub) {
        let clientId = "some_client_id"
        let client = AuthClientStub()
        let sut = ImgurAuthProvider(clientId: clientId, client: client)
        return (sut, client)
    }
}
