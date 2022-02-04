//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

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

    func test_authorize_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let error = NSError(domain: "unknown", code: 0)
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: .failure(error))
        }
    }
    
    func test_authorize_deliversErrorOnInsufficientParams() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(ImgurAuthProvider.Error.insufficientParams)) {
            let url = URL(string: "https://an-url.com/#access_token=")!
            client.complete(with: .success(url))
        }
    }
    
    func test_authorize_deliversAuthData() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://an-url.com/#access_token=some-token&account_username=some-name")!
        let authData = Account(accessToken: "some-token", accountName: "some-name")
        expect(sut, toCompleteWith: .success(authData)) {
            client.complete(with: .success(url))
        }
    }

    // MARK: - Helpers
    
    private func makeSUT() -> (ImgurAuthProvider, AuthClientStub) {
        let client = AuthClientStub()
        let sut = ImgurAuthProvider(clientId: "some_client_id", client: client)
        return (sut, client)
    }
}
