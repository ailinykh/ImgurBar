//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import XCTest
@testable import ImgurBar

class DropViewTests: XCTestCase {

    func test_initRegistersForDraggingTypes() {
        let view = DropView(frame: .zero)
        XCTAssertEqual(view.registeredDraggedTypes, [.fileURL, .fileContents])
    }

}
