//
//  PreferencesWindowController.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 04.12.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

class PreferencesTabController: NSTabViewController {
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        // FIXME: By default tabViewItem's size is 500x500
        // https://stackoverflow.com/a/54379220
        if let tabViewItem = tabViewItem, let viewController = tabViewItem.viewController {
            viewController.preferredContentSize = viewController.view.frame.size
        }
        super.tabView(tabView, didSelect: tabViewItem)
    }
}
