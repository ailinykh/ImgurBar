//
//  DropViewTests.swift
//  ImgurBarTests
//
//  Created by Anton Ilinykh on 17.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
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
