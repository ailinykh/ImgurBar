//
//  UserNotificationProvider.swift
//  ImgurBar
//
//  Created by Anton Ilinykh on 20.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Cocoa
import UserNotifications
import ImgurCore

@available(macOS 10.14, *)
final class UserNotificationProvider: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { authorized, error in
            if let error = error {
                print("UNUserNotificationCenter:", authorized, error)
            }
            print("UNUserNotificationCenter: authorized:", authorized)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        let action = UNNotificationAction(identifier: "OPEN_URL", title: "Open", options: [])
        
        let category = UNNotificationCategory(identifier: "IMAGE_UPLOADED", actions: [action], intentIdentifiers: ["OPEN_URL"], hiddenPreviewsBodyPlaceholder: "", options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let url = URL(string: response.notification.request.content.body) else {
            return
        }
            
        if response.actionIdentifier == "OPEN_URL" {
            NSWorkspace.shared.open(url)
        } else {
            NSPasteboard.general.declareTypes([.string], owner: nil)
            if !NSPasteboard.general.setString(url.absoluteString, forType: .string) {
                print("Can't copy to Pasteboard")
            }
        }
    }
}

extension UserNotificationProvider: NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = identifier
        content.body = text
        
        let request = UNNotificationRequest(identifier: "image_uploaded", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Can't send notification", error)
            }
        }
    }
}
