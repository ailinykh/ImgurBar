//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public final class ImgurUploader: ImageUploader {
    
    private let apiUrl = URL(string: "https://api.imgur.com/3/image")!
    
    struct Response: Decodable {
        struct Data: Decodable {
            var id: String?
            var type: String?
            var link: String?
            var error: String?
            var request: String?
            var method: String?
        }
        
        var data: Response.Data
        var success: Bool
        var status: Int
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidClientId
        case invalidData
        case tooManyRequests
    }
    
    let client: HTTPClient
    let auth: Authorization
    let builder: RequestBuilder
    
    public init(client: HTTPClient, auth: Authorization, builder: RequestBuilder) {
        self.client = client
        self.auth = auth
        self.builder = builder
    }
    
    public func upload(_ localImage: LocalImage, completion: @escaping (ImageUploader.Result) -> Void) {
        var request = try! builder.makeRequest(for: localImage.fileUrl)
        request.url = apiUrl
        switch auth {
        case .clientId(let clientId):
            request.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        case .bearerToken(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        client.perform(request: request) { result in
            switch result {
            case .success(let (data, _)):
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    
                    if !response.success {
                        switch response.status {
                        case 403:
                            throw Error.invalidClientId
                        default:
                            break
                        }
                    }
                    
                    guard let link = response.data.link, let url = URL(string: link) else {
                        throw Error.invalidData
                    }
                    let remoteImage = RemoteImage(url: url)
                    completion(.success(remoteImage))
                } catch {
                    completion(.failure(error as? Error ?? .invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
