//
//  AppDelegate.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 11.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Cocoa
import UserNotifications
import ImgurCore

extension URLSession: HTTPClient {
    public func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        uploadTask(with: request, from: request.httpBody) { data, response, error in
            guard let data = data, let response = response else {
                completion(.failure(error ?? NSError(domain: "unknown error", code: 0)))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
}

private final class LocalImageProviderFacade: LocalImageConsumer {
    let uploader: ImageUploader
    let completion: (ImageUploader.Result) -> Void
    
    init(provider: LocalImageProvider, uploader: ImageUploader, completion: @escaping (ImageUploader.Result) -> Void) {
        self.uploader = uploader
        self.completion = completion
        provider.add(consumer: self)
    }
    
    deinit {
        print(#function)
    }
    
    func consume(image localImage: LocalImage) {
        uploader.upload(localImage, completion: completion)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu: NSMenu!
    
    private var statusBarItem: NSStatusItem?
    private let view = DropView(frame: .zero)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        setupNotificationCenter()
        
        setupStatusBar()
        
        let uploader = ImgurUploader(client: URLSession.shared, clientId: "", builder: MultipartFormBuilder())
        
        _ = LocalImageProviderFacade(provider: view, uploader: uploader) { [weak self] result in
            switch (result) {
            case .success(let remoteImage):
                self?.sendNotification(with: remoteImage)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem!.button?.image = NSImage(named: "status_item")
        statusBarItem!.menu = menu
        
        view.frame = statusBarItem?.button?.frame ?? .zero
        statusBarItem!.button?.addSubview(view)
    }
    
    private func sendNotification(with remoteImage: RemoteImage) {
        let content = UNMutableNotificationContent()
        content.title = "Image uploaded"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "IMAGE_UPLOADED"
        content.body = remoteImage.url.absoluteString
        
        let request = UNNotificationRequest(identifier: "image_uploaded", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Can't send notification", error)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupNotificationCenter() {
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
