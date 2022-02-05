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
        let request = URLRequest(url: URL(string: "https://an-url")!)
        client.perform(request: request) { result in
            completion(.success([]))
        }
    }
}

class ImgurAlbumLoaderUsecaseTests: XCTestCase {
    func test_albumLoaderCallsHTTPClientLoadMethod() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            client.complete(with: Data(), response: .any)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: ImgurAlbumLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = ImgurAlbumLoader(client: client)
        return (sut, client)
    }
}
