//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public class ImgurAlbumLoader: AlbumLoader {
    public enum Error: Swift.Error, Equatable {
        case invalidData
        case badRequest(String)
    }
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(for account: Account, completion: @escaping (Result<[Album], Swift.Error>) -> Void) {
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
