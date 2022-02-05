//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import ImgurCore
import XCTest

class ImgurAlbumLoader: AlbumLoader {
    public enum Error: Swift.Error, Equatable {
        case invalidData
        case badRequest(String)
    }
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(for account: Account, completion: @escaping (Result<[Album], Swift.Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://an-url")!)
        request.setValue("Bearer: \(account.token)", forHTTPHeaderField: "Authorization")
        client.perform(request: request) { result in
            switch result {
            case .success(let (data, _)):
                do {
                    let albums = try ImgurAlbumMapper.map(data: data)
                    completion(.success(albums))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private final class ImgurAlbumMapper {
    struct ResponseSuccess: Decodable {
        struct Album: Decodable {
            let id: String
            let title: String
        }
        
        var data: [Album]
        var success: Bool
        var status: Int
    }
    
    struct ResponseFailure: Decodable {
        struct Error: Decodable {
            let error: String
            let request: String
            let method: String
        }
        
        var data: Error
        var success: Bool
        var status: Int
    }
    
    static func map(data: Data) throws -> [Album] {
        do {
            let response = try JSONDecoder().decode(ResponseSuccess.self, from: data)
            return response.data.map({Album(id: $0.id, title: $0.title)})
        } catch {
            if let response = try? JSONDecoder().decode(ResponseFailure.self, from: data) {
                throw ImgurAlbumLoader.Error.badRequest(response.data.error)
            }
        }
        throw ImgurAlbumLoader.Error.invalidData
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
