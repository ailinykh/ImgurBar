//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import ImgurCore
import XCTest

class ImgurAlbumLoader: AlbumLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(for account: Account, completion: @escaping (Result<[Album], Error>) -> Void) {
        
    }
}

class ImgurAlbumLoaderUsecaseTests: XCTestCase {
    func test_albumLoaderDoesNoeLoadAnythingOnInit() {
        let client = HTTPClientSpy()
        let _ = ImgurAlbumLoader(client: client)
        XCTAssertEqual(client.messages.count, 0)
    }
}

private final class HTTPClientSpy: HTTPClient {
    private(set) var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((request, completion))
    }
    
    func getRequest(at index: Int = 0) -> URLRequest {
        return messages[index].request
    }
    
    func complete(with data: Data, response: HTTPURLResponse, at index: Int = 0) {
        messages[index].completion(.success((data, response)))
    }
}
