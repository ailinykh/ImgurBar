//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

extension ImgurAuthProviderUseCaseTests {
    func expect(_ sut: ImgurAuthProvider, toCompleteWith expectedResult: Result<Account, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Authorization expectation")
        sut.authorize { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData.accessToken, receivedData.accessToken, file: file, line: line)
                XCTAssertEqual(expectedData.username, receivedData.username, file: file, line: line)
            case (.failure(let expectedError as NSError), .failure(let receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("expected: \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
