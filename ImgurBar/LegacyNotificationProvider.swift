//
//  LegacyNotificationProvider.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 22.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation
import ImgurCore

final class LegacyNotifiactionProvider: NSObject, NSUserNotificationCenterDelegate {
    
    override init() {
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print(#function, notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print(#function, notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        print(#function, notification)
        return true
    }
}

extension LegacyNotifiactionProvider: NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String) {
        let note = NSUserNotification()
        note.identifier = UUID().uuidString
        note.title = title
        note.informativeText = text
        note.actionButtonTitle = "Open"
        NSUserNotificationCenter.default.scheduleNotification(note)
    }
}
