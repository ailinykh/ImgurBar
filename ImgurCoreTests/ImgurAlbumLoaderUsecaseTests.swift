//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import ImgurCore
import XCTest

class ImgurAlbumLoader: AlbumLoader {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(for account: Account, completion: @escaping (Result<[Album], Swift.Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://an-url")!)
        request.setValue("Bearer: \(account.token)", forHTTPHeaderField: "Authorization")
        client.perform(request: request) { result in
            completion(.success([]))
        }
    }
}

class ImgurAlbumLoaderUsecaseTests: XCTestCase {
    func test_albumLoaderSetsAuthorizationTokenForRequest() {
        let (sut, client) = makeSUT()
        let account = Account(token: "some-token", username: "some-username")
        
        sut.load(for: account) { _ in }
        
        let request = client.getRequest()
        let authorization = request.value(forHTTPHeaderField:"Authorization")
        XCTAssertEqual(authorization, "Bearer: some-token")
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: ImgurAlbumLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = ImgurAlbumLoader(client: client)
        return (sut, client)
    }
}
