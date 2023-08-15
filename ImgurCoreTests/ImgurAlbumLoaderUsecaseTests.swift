//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import ImgurCore
import XCTest

class ImgurAlbumLoaderUsecaseTests: XCTestCase {
    func test_loadSetsAuthorizationTokenForRequest() {
        let (sut, client) = makeSUT()
        let account = Account(
            accessToken: "some-token",
            refreshToken: "refresh-token",
            expiresIn: 86400,
            username: "some-username")
        
        sut.load(for: account) { _ in }
        
        let request = client.getRequest()
        let authorization = request.value(forHTTPHeaderField:"Authorization")
        XCTAssertEqual(authorization, "Bearer some-token")
    }
    
    func test_loadDeliversAlbumsOnSuccess() {
        let (sut, client) = makeSUT()
        let albums = [
            Album(id: "album1Id", title: "album1Title"),
            Album(id: "album2Id", title: "album2Title"),
        ]
        
        expect(sut, toCompleteWith: .success(albums)) {
            client.complete(with: makeResponseData(for: albums), response: .any)
        }
    }
    
    func test_loadDeliversErrorOnInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.complete(with: "invalid json".data(using: .utf8)!, response: .any)
        }
    }
    
    func test_loadDeliversErrorOnBadRequest() {
        let (sut, client) = makeSUT()
        let error = ImgurAlbumLoader.Error.badRequest("The access token provided is invalid.")
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: makeResponseError(), response: .any)
        }
    }
    
    //MARK: - Helpers
    
    private func makeResponseData(for albums: [Album], status: Int = 0) -> Data {
        let json = [
            "data": albums.map {
                ["id": $0.id, "title": $0.title]
            },
            "success": status == 0,
            "status": status
        ].compactMapValues { $0 }
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeResponseError() -> Data {
        let json = [
            "data": [
                "error": "The access token provided is invalid.",
                "request": "/3/account/username/albums/",
                "method": "GET"
            ],
            "success": false,
            "status": 403
        ].compactMapValues { $0 }
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeSUT() -> (sut: ImgurAlbumLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = ImgurAlbumLoader(client: client)
        return (sut, client)
    }
}
