//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import ImgurCore
import XCTest

class ImgurAlbumLoader: AlbumLoader {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    struct Response: Decodable {
        struct RemoteAlbum: Decodable {
            let id: String
            let title: String
        }
        
        var data: [RemoteAlbum]
        var success: Bool
        var status: Int
    }
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(for account: Account, completion: @escaping (Result<[Album], Swift.Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://an-url")!)
        request.setValue("Bearer: \(account.token)", forHTTPHeaderField: "Authorization")
        client.perform(request: request) { result in
            if let (data, _) = try? result.get() {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(response.data.map({Album(id: $0.id, title: $0.title)})))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
}

class ImgurAlbumLoaderUsecaseTests: XCTestCase {
    func test_loadSetsAuthorizationTokenForRequest() {
        let (sut, client) = makeSUT()
        let account = Account(token: "some-token", username: "some-username")
        
        sut.load(for: account) { _ in }
        
        let request = client.getRequest()
        let authorization = request.value(forHTTPHeaderField:"Authorization")
        XCTAssertEqual(authorization, "Bearer: some-token")
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
    
    private func makeSUT() -> (sut: ImgurAlbumLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = ImgurAlbumLoader(client: client)
        return (sut, client)
    }
}
