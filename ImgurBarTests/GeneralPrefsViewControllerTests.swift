//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import XCTest
@testable import ImgurBar

class GeneralPrefsViewControllerTests: XCTestCase {

    func test_onLaunchOnSystemStartupChanged_deliversBoolOnChange() {
        let viewController = makeSUT()
        var changes = [Bool]()
        
        viewController.onLaunchOnSystemStartupChanged = { change in
            changes.append(change)
        }
        
        XCTAssertEqual(changes, [])
        
        viewController.launchOnSystemStartup = false
        
        XCTAssertEqual(changes, [false])
        
        let checkbox = viewController.view.subviews.first! as! NSButton
        checkbox.performClick(nil)
        
        XCTAssertEqual(changes, [false, true])
    }
    
    func test_onUploadScreenshotsChanged_deliversUploadScreenshotSetting() {
        let viewController = makeSUT()
        var changes = [Bool]()
        
        viewController.onUploadScreenshotsChanged = { change in
            changes.append(change)
        }
        
        XCTAssertEqual(changes, [])
        
        viewController.uploadScreenshots = false
        
        XCTAssertEqual(changes, [false])
        
        let checkbox = viewController.view.subviews[1] as! NSButton
        checkbox.performClick(nil)
        
        XCTAssertEqual(changes, [false, true])
    }

    private func makeSUT() -> GeneralPrefsViewController {
        let storyboard = NSStoryboard(name: "Preferences", bundle: .main)
        let windowController = storyboard.instantiateInitialController() as! PreferencesWindowController
        let tab = windowController.window!.contentViewController as! PreferencesTabViewController
        let generalPrefsViewController = tab.tabViewItems.first!.viewController as! GeneralPrefsViewController
        
        return generalPrefsViewController
    }
}
