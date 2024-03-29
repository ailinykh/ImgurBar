//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

class ImgurUploaderUseCaseTests: XCTestCase {
    
    func test_upload_setAuthorizationHeader() {
        let (sut, client) = makeSUT()
        let fileUrl = URL(fileURLWithPath: "a-path")
        let localImage = LocalImage(fileUrl: fileUrl)
        sut.upload(localImage) { _ in }
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
    
    func test_upload_deliversInvalidClientIdError() {
        let (sut, client) = makeSUT()
        let error = makeResponseError(code: 403, message: "Invalid client_id")
        
        expect(sut, toCompleteWith: .failure(.invalidClientId)) {
            client.complete(with: error, response: .any)
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
        let sut = ImgurUploader(client: client, auth: .clientId("SECRET_CLIENT_ID"), builder: builder)
        return (sut, client)
    }
}

private final class RequestBuilderStub: RequestBuilder {
    func makeRequest(for fileUrl: URL) -> URLRequest {
        URLRequest(url: fileUrl)
    }
}
