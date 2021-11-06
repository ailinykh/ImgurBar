//
//  ImgurImageUploaderUseCasesTests.swift
//  ImgurCoreTests
//
//  Created by Anton Ilinykh on 04.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import XCTest
import ImgurCore

final class ImgurImageUploader: ImageUploader {
    
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
    
    let client: HTTPClient
    let clientId: String
    
    init(client: HTTPClient, clientId: String) {
        self.client = client
        self.clientId = clientId
    }
    
    func upload(url: URL, completion: @escaping (ImageUploader.Result) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        client.perform(request: request) { result in
            switch result {
            case .success(let (_, _)):
                completion(.success(URL(string: "a-remote-image-url")!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class ImgurImageUploaderUseCasesTests: XCTestCase {
    
    func test_upload_setAuthorizationHeader() {
        let (sut, client) = makeSUT()
        let fileUrl = URL(fileURLWithPath: "a-path")
        
        sut.upload(url: fileUrl) { _ in }
        client.complete(with: Data(), response: .any)
        
        let request = client.getRequest()
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func test_upload_deliversRemoteImageURL() {
        let (sut, client) = makeSUT()
        let fileUrl = URL(fileURLWithPath: "a-path")
        let remoteImageUrl = URL(string: "a-remote-image-url")!
        let exp = XCTestExpectation(description: "image upload expectation")
        
        sut.upload(url: fileUrl) { result in
            switch result {
            case .failure:
                XCTFail("Expected succes but gor error")
            case .success(let url):
                XCTAssertEqual(url, remoteImageUrl)
            }
            exp.fulfill()
        }
        client.complete(with: makeResponseData(for: remoteImageUrl), response: HTTPURLResponse())
        
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers
    
    private func makeResponseData(for url: URL) -> Data {
        let json = """
        {
            "data": {
                "id": "id",
                "type": "type",
                "link": "\(url.absoluteString)"
            },
            "success": true,
            "status": 0
        }
        """
        return try! JSONEncoder().encode(json)
    }
    
    private func makeSUT() -> (sut: ImgurImageUploader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = ImgurImageUploader(client: client, clientId: "CLIENT_ID")
        return (sut, client)
    }
}


private final class HTTPClientSpy: HTTPClient {
    private var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
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

private extension HTTPURLResponse {
    static var any: HTTPURLResponse {
        return HTTPURLResponse()
    }
}
