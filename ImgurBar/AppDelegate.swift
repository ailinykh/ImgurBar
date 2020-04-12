//
//  AppDelegate.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 11.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Cocoa
import Combine
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu: NSMenu!
    
    private var subscriptions = Set<AnyCancellable>()
    private var statusBarItem: NSStatusItem?
    private let observer = ScreenshotsObserver()
    private let view = DraggableView(frame: .zero)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        setupNotificationCenter()
        
        setupStatusBar()
        
        let client = Client()
        
        observer.screenshotsPubliser
            .merge(with: view.imagePublisher)
            .handleEvents(receiveOutput: { [unowned self] _ in
                self.statusBarItem?.button?.startAnimation()
            })
            .flatMap { client.upload($0) }
            .handleEvents(receiveOutput: { [unowned self] _ in
                self.statusBarItem?.button?.stopAnimation()
            })
            .filter { $0.success }
            .sink(receiveCompletion: { [unowned self] completion in
                print("Completion received", completion)
                self.statusBarItem?.button?.stopAnimation()
            }, receiveValue: { response in
                print("Value received", response.data.link)
                
                let content = UNMutableNotificationContent()
                content.title = "Image uploaded"
                content.body = response.data.link
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "IMAGE_UPLOADED"
                
                let request = UNNotificationRequest(identifier: "image_uploaded", content: content, trigger: nil)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Can't send notification", error)
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
    func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem!.button?.image = NSImage(named: "status_item")
        statusBarItem!.menu = menu
        
        view.frame = statusBarItem?.button?.frame ?? .zero
        statusBarItem!.button?.addSubview(view)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupNotificationCenter() {
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { authorized, error in
            if let error = error {
                print("UNUserNotificationCenter:", authorized, error)
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        let action = UNNotificationAction(identifier: "OPEN_URL", title: "Open", options: [])
        
        let category = UNNotificationCategory(identifier: "IMAGE_UPLOADED", actions: [action], intentIdentifiers: ["OPEN_URL"], hiddenPreviewsBodyPlaceholder: "", options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
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
