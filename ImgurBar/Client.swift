//
//  Client.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 11.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Foundation
import Combine

class Client {
    private let CLIENT_ID = ""
    private var subscriptions = Set<AnyCancellable>()
    
    struct ResponseData: Decodable {
        var id: String
        var type: String
        var link: String
    }
    
    struct Response: Decodable {
        var data: ResponseData
        var success: Bool
        var status: Int
    }
    
    func upload(_ data: Data) -> AnyPublisher<Response, Never> {
        let url = URL(string: "https://api.imgur.com/3/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID \(CLIENT_ID)", forHTTPHeaderField: "Authorization")
        request.httpBody = data

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Response.self, decoder: JSONDecoder())
            .replaceError(with: Response(data: ResponseData(id: "", type: "", link: ""), success: false, status: 0))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
