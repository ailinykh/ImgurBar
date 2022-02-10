//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import XCTest
import ImgurCore
@testable import ImgurBar

class PreferencesPresenterTests: XCTestCase {
    func test_presenterCreatesCorrectComposition() {
        let authProvider = AuthProviderStub()
        let screenshotService = ScreenshotUploadService { _ in }
        let presenter = PreferencesPresenter(localAuthProvider: authProvider, remoteAuthProvider: authProvider, screenshotService: screenshotService)
        
        let windowController = presenter.makeController()
        let tabViewController = windowController.contentViewController as? NSTabViewController
        let generalPreferencesViewController = tabViewController?.children.first as? GeneralPrefsViewController
        
        XCTAssertNotNil(tabViewController)
        XCTAssertNotNil(generalPreferencesViewController)
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
