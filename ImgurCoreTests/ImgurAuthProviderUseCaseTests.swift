//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

class ImgurAuthProvider: AuthProvider {
    
    let clientId: String
    let client: AuthClient
    
    enum Error: Swift.Error {
        case invalidUrlRedirect
        case insufficientParams
    }
    
    init(clientId: String, client: AuthClient) {
        self.clientId = clientId
        self.client = client
    }
    
    func authorize(completion: @escaping (Result<AuthData, Swift.Error>) -> Void) {
            let url = URL(string:"https://api.imgur.com/oauth2/authorize?client_id=\(clientId)&response_type=token")!
            client.open(url: url) { [weak self] result in
                switch result {
                case .success(let url):
                    do {
                        let authData = try self!.handle(url: url)
                        completion(.success(authData))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private func handle(url: URL) throws -> AuthData {
            let parts = url.absoluteString.split(separator: "#")
            guard parts.count > 1, let path = parts.last
            else {
                throw Error.invalidUrlRedirect
            }
            
            let dict = parse(path: String(path))
            guard let token = dict["access_token"], let account = dict["account_username"] else {
                throw Error.insufficientParams
            }
            
            return AuthData(accessToken: token, accountName: account)
        }
        
        private func parse(path: String) -> [String: String] {
            return path.split(separator: "&")
                .reduce([String:String](), { partialResult, part in
                    var partialResult = partialResult
                    let parts = part.split(separator: "=")
                    if let key = parts.first, let value = parts.last {
                        partialResult[String(key)] = String(value)
                    }
                    return partialResult
                })
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
        let authData = AuthData(accessToken: "some-token", accountName: "some-name")
        expect(sut, toCompleteWith: .success(authData)) {
            client.complete(with: .success(url))
        }
    }
    
    private func expect(_ sut: ImgurAuthProvider, toCompleteWith expectedResult: Result<AuthData, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Authorization expectation")
        sut.authorize { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData.accessToken, receivedData.accessToken, file: file, line: line)
                XCTAssertEqual(expectedData.accountName, receivedData.accountName, file: file, line: line)
            case (.failure(let expectedError as NSError), .failure(let receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("expected: \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> (ImgurAuthProvider, AuthClientStub) {
        let client = AuthClientStub()
        let sut = ImgurAuthProvider(clientId: "some_client_id", client: client)
        return (sut, client)
    }
}
