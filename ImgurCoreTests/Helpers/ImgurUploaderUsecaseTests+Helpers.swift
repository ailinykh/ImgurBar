//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

extension ImgurUploaderUseCaseTests {
    func expect(_ sut: ImgurUploader, toCompleteWith expectedResult: Swift.Result<URL, ImgurUploader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for upload completion")
        let fileUrl = URL(fileURLWithPath: "a-path")
        let localImage = LocalImage(fileUrl: fileUrl)
        
        sut.upload(localImage) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(remoteImage), .success(expectedUrl)):
                XCTAssertEqual(remoteImage.url, expectedUrl, file: file, line: line)
            case let (.failure(receivedError as ImgurUploader.Error), .failure(expectedError)):
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
