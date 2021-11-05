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
    
    func upload(image: LocalImage, completion: @escaping (ImageUploader.Result) -> Void) {
        let anError = NSError(domain: "error", code: 0)
        completion(.failure(anError))
    }
}

class ImgurImageUploaderUseCasesTests: XCTestCase {

    func test_upload_deliversRemoteImage() {
        let sut = ImgurImageUploader()
        let fileUrl = URL(fileURLWithPath: "a-path")
        let localImage = LocalImage(fileUrl: fileUrl)
        let exp = XCTestExpectation(description: "image upload expectation")
        
        sut.upload(image: localImage) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }

}
