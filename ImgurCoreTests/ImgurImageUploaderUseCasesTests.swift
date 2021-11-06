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
    
    func upload(from: URL, completion: @escaping (ImageUploader.Result) -> Void) {
        let url = URL(string: "a-remote-image-url")!
        completion(.success(url))
    }
}

class ImgurImageUploaderUseCasesTests: XCTestCase {

    func test_upload_deliversRemoteImageURL() {
        let sut = ImgurImageUploader()
        let fileUrl = URL(fileURLWithPath: "a-path")
        let remoteImageUrl = URL(string: "a-remote-image-url")!
        let exp = XCTestExpectation(description: "image upload expectation")
        
        sut.upload(from: fileUrl) { result in
            switch result {
            case .failure:
                XCTFail("Expected succes but gor error")
            case .success(let url):
                XCTAssertEqual(url, remoteImageUrl)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }

}
