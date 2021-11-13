//
//  ImgurUploaderUsecaseTests+Helpers.swift
//  ImgurCoreTests
//
//  Created by Anton Ilinykh on 13.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import XCTest

extension ImgurUploaderUseCaseTests {
    func expect(_ sut: ImgurImageUploader, toCompleteWith expectedResult: Swift.Result<URL, ImgurImageUploader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for upload completion")
        let fileUrl = URL(fileURLWithPath: "a-path")
        
        sut.upload(url: fileUrl) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedURL), .success(expectedUrl)):
                XCTAssertEqual(receivedURL, expectedUrl, file: file, line: line)
            case let (.failure(receivedError as ImgurImageUploader.Error), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: 0.1)
    }
}
