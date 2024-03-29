//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import UserNotifications
import ImgurCore

@available(macOS 10.14, *)
final class UserNotificationProvider: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        
        checkAuthorizationStatus()
        
        UNUserNotificationCenter.current().delegate = self
        
        let action = UNNotificationAction(
            identifier: "OPEN_URL",
            title: "Open",
            options: [])
        
        let category = UNNotificationCategory(
            identifier: .imageUploadCompleted,
            actions: [action],
            intentIdentifiers: ["OPEN_URL"],
            hiddenPreviewsBodyPlaceholder: "",
            options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { authorized, error in
            print("UNUserNotificationCenter - authorized:", authorized, error ?? "")
            NotificationCenter.default.post(
                name: .notificationCenterAuthorizationStatusChanged,
                object: authorized)
            // TODO: - find proprietary way to discover auth status changes
            if !authorized {
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.checkAuthorizationStatus()
                }
            }
        }
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

@available(macOS 10.14, *)
extension UserNotificationProvider: NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = identifier
        content.body = text
        
        let request = UNNotificationRequest(
            identifier: .imageUploadCompleted,
            content: content,
            trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Can't send notification", error)
            }
        }
    }
}
