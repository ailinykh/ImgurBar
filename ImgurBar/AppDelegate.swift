//
//  AppDelegate.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 11.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Cocoa
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
    private let nontificationProvider = UserNotificationProvider()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        setupStatusBar()
        
        guard let clientId = Bundle.main.infoDictionary?["imgur_client_id"] as? String else {
            preconditionFailure("Please retreive the `client_id` from https://api.imgur.com/oauth2/addclient and add it to Info.plist for key `imgur_client_id`")
        }
        
        let uploader = ImgurUploader(client: URLSession.shared, clientId: clientId, builder: MultipartFormBuilder())
        
        _ = LocalImageProviderFacade(provider: view, uploader: uploader) { [weak self] result in
            switch (result) {
            case .success(let remoteImage):
                self?.nontificationProvider.sendNotification(with: remoteImage)
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
}
