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
