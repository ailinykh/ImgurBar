//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

class MultipartFormBuilderUseCaseTests: XCTestCase {
    
    func test_makeRequest_setsMultipartFormParameters() throws {
        let sut = MultipartFormBuilder()
        let fileName = UUID().uuidString + ".png"
        let data = "binary data".data(using: .utf8)!
        let fileUrl = makeTmpFile(name: fileName, data: data)
        
        let request = try sut.makeRequest(for: fileUrl)
        
        XCTAssertNotNil(request.httpBody)
        let string = String(data: request.httpBody!, encoding: .utf8)!
        
        XCTAssertTrue(string.contains("Content-Disposition: form-data;"))
        XCTAssertTrue(string.contains("filename=\"\(fileName)\""))
        XCTAssertTrue(string.contains("Content-Type: image/png"), string)
    }
    
    func test_makeRequest_throwsAnErrorInCaseOfBadFile() throws {
        let sut = MultipartFormBuilder()
        let fileName = UUID().uuidString + ".png"
        let fileUrl = makeTmpFile(name: fileName)
        
        XCTAssertThrowsError(try sut.makeRequest(for: fileUrl))
    }
    
    private func makeTmpFile(name: String, data: Data? = nil) -> URL {
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        if let data = data {
            try! data.write(to: fileUrl)
        }
        return fileUrl
    }
}
