//
//  ImgurUploaderUseCaseTests.swift
//  ImgurCoreTests
//
//  Created by Anton Ilinykh on 04.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import XCTest
import ImgurCore

class ImgurUploaderUseCaseTests: XCTestCase {
    
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
        let remoteImageUrl = URL(string: "some-remote-image-url")!
        
        expect(sut, toCompleteWith: .success(remoteImageUrl)) {
            client.complete(with: makeResponseData(for: remoteImageUrl), response: .any)
        }
    }
    
    func test_upload_deliversErrorOnInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.complete(with: "invalid json".data(using: .utf8)!, response: .any)
        }
    }
    
    func test_upload_deliversErrorOnApiError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.complete(with: makeResponseError(), response: .any)
        }
    }

    // MARK: - Helpers
    private func makeResponseError(code: UInt = 400, message: String = "Bad Request") -> Data {
        let json = [
            "data": [
                "error": message,
                "request": "/3/upload",
                "method": "POST"
            ],
            "success": false,
            "status": code
        ].compactMapValues { $0 }
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeResponseData(for url: URL) -> Data {
        let json = [
            "data": [
                "id": "id",
                "type": "type",
                "link": "\(url.absoluteString)"
            ],
            "success": true,
            "status": 0
        ].compactMapValues { $0 }
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeSUT() -> (sut: ImgurUploader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let builder = RequestBuilderStub()
        let sut = ImgurUploader(client: client, clientId: "SECRET_CLIENT_ID", builder: builder)
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

private final class RequestBuilderStub: RequestBuilder {
    func makeRequest(for fileUrl: URL) -> URLRequest {
        URLRequest(url: fileUrl)
    }
}

private extension HTTPURLResponse {
    static var any: HTTPURLResponse {
        return HTTPURLResponse()
    }
}
