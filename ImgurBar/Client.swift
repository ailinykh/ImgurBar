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
    private let CLIENT_ID = "<INSERT_YOUR_API_KEY_HERE>"
    
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
    
    func upload(_ fileUrl: URL) -> AnyPublisher<Response, Never> {
        let url = URL(string: "https://api.imgur.com/3/upload")!
        let makeRandom = { UInt32.random(in: (.min)...(.max)) }
        let boundary = String(format: "--------%08X%08X", makeRandom(), makeRandom())
        let body = URLSession.shared.multipartFormData(for: fileUrl, with: boundary)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID \(CLIENT_ID)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)",
                    forHTTPHeaderField: "Content-Type")
        request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
        
        return URLSession.shared
            .uploadTaskPublisher(for: request, with: body)
            .map(\.data)
            .handleEvents(receiveOutput: { data in print(String(data: data, encoding: .utf8) ?? "nil") })
            .decode(type: Response.self, decoder: JSONDecoder())
            .replaceError(with: Response(data: ResponseData(id: "", type: "", link: ""), success: false, status: 0))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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

private extension URLSession {
    func uploadTaskPublisher(for request: URLRequest, with data: Data) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        let subject = PassthroughSubject<(data: Data, response: URLResponse), Error>()
        
        uploadTask(with: request, from: data) { data, response, error in
            guard let data = data, let response = response else {
                let error = error ?? NSError(domain: "unknown", code: 0)
                return subject.send(completion: .failure(error))
            }
            
            subject.send((data, response))
        }.resume()
        
        return subject.eraseToAnyPublisher()
    }
    
    func multipartFormData(for url: URL, with boundary: String) -> Data {
        let name = url.deletingPathExtension().lastPathComponent
        let filename = url.lastPathComponent
        let mime = FileManager.default.mimeType(for: url)
        let data = try! Data(contentsOf: url)
        var body = Data()
        body.append("--\(boundary)\r\n".data)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data)
        body.append("Content-Type: \(mime)\r\n\r\n".data)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data)
        return body
    }
}

private extension FileManager {
    func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

private extension String {
    var data: Data { self.data(using: .utf8)! }
}
