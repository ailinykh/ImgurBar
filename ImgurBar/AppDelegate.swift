//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import ImgurCore

let helperBundleIdentifier = "com.ailinykh.ImgurBarHelper"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu: NSMenu!
    
    private let view = DropView(frame: .zero)
    private let httpClient = URLSession.shared
    private lazy var statusBarItem: NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(named: "status_item")
        item.menu = menu
        
        view.frame = item.button?.frame ?? .zero
        item.button?.addSubview(view)
        return item
    }()
    
    private lazy var notificationProvider: NotificationProvider = {
        guard #available(macOS 10.14, *) else {
            return LegacyNotifiactionProvider()
        }
        return UserNotificationProvider()
    }()
    
    private let authClient: AuthClient = {
        guard #available(macOS 10.15, *) else {
            return LegacyAuthClient()
        }
        return ModernAuthClient()
    }()
    
    private var screenshotService: ScreenshotUploadService!

    private let clientId: String = {
#if DEBUG
        guard let clientId = ProcessInfo.processInfo.environment["imgur_client_id"] else {
            return "FAKE_CLIENT_ID"
        }
#else
        guard let clientId = Bundle.main.infoDictionary?["imgur_client_id"] as? String, !clientId.isEmpty else {
            preconditionFailure("Please retreive the `client_id` from https://api.imgur.com/oauth2/addclient and add it to Info.plist for key `imgur_client_id`")
        }
#endif
        return clientId
    }()
    
    private lazy var preferencesPresenter: PreferencesPresenter = {
        let localAuthProvider = LocalAuthProvider(storage: DefaultsService())
        let imgurAuthProvider = ImgurAuthProvider(clientId: clientId, client: authClient)
        let authProviderMainThreadDecorator = AuthProviderMainThreadDecorator(decoratee: imgurAuthProvider)
        return PreferencesPresenter(localAuthProvider: localAuthProvider, remoteAuthProvider: authProviderMainThreadDecorator, screenshotService: screenshotService)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = statusBarItem // trigger icon appear
        terminateLauncherIfNeeded()
        
        let uploader = ImageUploaderMainThreadDecorator(decoratee: ImgurUploader(client: httpClient, clientId: clientId, builder: MultipartFormBuilder()))
        
        let facade = LocalImageProviderFacade() { [weak self] localImage in
            self?.statusBarItem.button?.startAnimation()
            
            uploader.upload(localImage) { result in
                switch (result) {
                case .success(let remoteImage):
                    self?.notificationProvider.sendNotification(identifier: "IMAGE_UPLOADED", title: "Image uploaded", text: remoteImage.url.absoluteString)
                case .failure(let error):
                    print(error)
                }
                self?.statusBarItem.button?.stopAnimation()
            }
        }
        
        screenshotService = ScreenshotUploadService() { [weak facade] url in
            let localImage = LocalImage(fileUrl: url)
            facade?.consume(image: localImage)
        }
        
        view.add(consumer: facade)
        _ = notificationProvider // initialize provider
    }
    
    @IBAction func openPreferencesAction(_ sender: Any?) {
        let preferencesWindowController = preferencesPresenter.makeController()
        preferencesWindowController.showWindow(sender)
        preferencesWindowController.window?.makeKeyAndOrderFront(sender)
    }
    
    @IBAction func enableNotificationsAction(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach {
            NotificationCenter.default.post(name: .applicationOpenUrl, object: $0)
        }
    }
    
    // MARK: - private
    
    private func terminateLauncherIfNeeded() {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == helperBundleIdentifier }.isEmpty

        if isRunning {
            DistributedNotificationCenter.default().post(name: .terminateLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
}
