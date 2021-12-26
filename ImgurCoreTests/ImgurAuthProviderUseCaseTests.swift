//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore

class ImgurAuthProvider: AuthProvider {
    func authorize(completion: @escaping (Result<AuthData, Error>) -> Void) {
        let error = NSError(domain: "unknown", code: 0)
        completion(.failure(error))
    }
}

class ImgurAuthProviderUseCaseTests: XCTestCase {

    func test_authorize_deliversAuthResult() {
        let sut = ImgurAuthProvider()
        let exp = expectation(description: "Authorization expectation")
        
        sut.authorize { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }

}
