//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

extension ImgurAlbumLoaderUsecaseTests {
    func expect(_ sut: ImgurAlbumLoader, toCompleteWith expectedResult: Swift.Result<[Album], ImgurAlbumLoader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for upload completion")
        let account = Account(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresIn: 86400,
            username: "some-username")
        
        sut.load(for: account) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(received), .success(expected)):
                XCTAssertEqual(received, expected, file: file, line: line)
            case let (.failure(receivedError as ImgurAlbumLoader.Error), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: 0.1)
    }
}
