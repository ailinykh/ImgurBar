//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore
@testable import ImgurBar

class PreferencesPresenterTests: XCTestCase {
    func test_presenterCreatesCorrectComposition() {
        let presenter = makeSUT()
        
        let windowController: PreferencesWindowController? = presenter.makeController()
        let tabViewController = windowController?.contentViewController as? NSTabViewController
        let viewController = tabViewController?.children.first as? GeneralPrefsViewController
        
        XCTAssertNotNil(windowController)
        XCTAssertNotNil(tabViewController)
        XCTAssertNotNil(viewController)
    }
    
    private func makeSUT() -> PreferencesPresenter {
        let authProvider = AuthProviderStub()
        let screenshotService = ScreenshotUploadService { _ in }
        let sut = PreferencesPresenter(
            localAuthProvider: authProvider,
            remoteAuthProvider: authProvider,
            screenshotService: screenshotService)
        trackForMemoryLeaks(sut)
        return sut
    }
}

private class AuthProviderStub: PersistentAuthProvider {
    func save(account: Account) {
        
    }
    
    func remove() {
        
    }
    
    func authorize(completion: @escaping (Result<Account, Error>) -> Void) {
        
    }
}
