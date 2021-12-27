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
    private var completions = [(Result<URL, Error>) -> Void]()
    
    func open(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        completions.append(completion)
    }
    
    func complete(with result: Result<URL, Error>, at: Int = 0) {
        completions[at](result)
    }
}

class ImgurAuthProviderUseCaseTests: XCTestCase {

    func test_authorize_deliversAnyAuthResult() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Authorization expectation")
        
        sut.authorize { result in
            exp.fulfill()
        }
        
        let url = URL(string: "https://an-url.com")!
        client.complete(with: .success(url))
        
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> (ImgurAuthProvider, AuthClientStub) {
        let client = AuthClientStub()
        let sut = ImgurAuthProvider(clientId: "some_client_id", client: client)
        return (sut, client)
    }
}
