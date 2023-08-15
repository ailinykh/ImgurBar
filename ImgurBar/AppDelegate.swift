//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import ImgurCore

extension String {
    static let helperBundleIdentifier = "com.ailinykh.ImgurBarHelper"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu: NSMenu!
    
    private weak var preferencesWindow: NSWindow?
    
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
    
    private lazy var localAuthProvider: PersistentAuthProvider = {
#if DEBUG
        let storage = DefaultsService()
#else
        let storage = KeychainService()
#endif
        return LocalAuthProvider(storage: storage)
    }()
    
    private lazy var preferencesPresenter: PreferencesPresenter = {
        let imgurAuthProvider = ImgurAuthProvider(clientId: clientId, client: authClient)
        let authProviderMainThreadDecorator = AuthProviderMainThreadDecorator(decoratee: imgurAuthProvider)
        return PreferencesPresenter(
            localAuthProvider: localAuthProvider,
            remoteAuthProvider: authProviderMainThreadDecorator,
            screenshotService: screenshotService)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = statusBarItem // trigger icon appear
        terminateLauncherIfNeeded()
        
        var uploader = makeUploader()
        
        NotificationCenter.default.addObserver(
            forName: .userAuthorizationStatusChanged,
            object: nil,
            queue: nil
        ) { [weak self] note in
            if let u = self?.makeUploader(account: note.object as? Account) {
                uploader = u
            }
        }
        
        localAuthProvider.authorize(completion: { [weak self] result in
            if let account = try? result.get(), let u = self?.makeUploader(account: account) {
                uploader = u
            }
        })
        
        let facade = LocalImageProviderFacade() { [weak self] localImage in
            self?.statusBarItem.button?.startAnimation()
            
            uploader.upload(localImage) { result in
                switch (result) {
                case .success(let remoteImage):
                    self?.notificationProvider.sendNotification(
                        identifier: .imageUploadCompleted,
                        title: "Image uploaded",
                        text: remoteImage.url.absoluteString)
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
        // prevent multiple windows opening
        if let preferencesWindow = preferencesWindow {
            preferencesWindow.orderFrontRegardless()
        } else {
            let preferencesWindowController = preferencesPresenter.makeController()
            preferencesWindowController.showWindow(sender)
            preferencesWindowController.window?.makeKeyAndOrderFront(sender)
            preferencesWindow = preferencesWindowController.window
        }
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
        let isRunning = !runningApps.filter {
            $0.bundleIdentifier == .helperBundleIdentifier
        }.isEmpty

        if isRunning {
            DistributedNotificationCenter.default().post(name: .terminateLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
    
    private func makeUploader(account: Account? = nil) -> ImageUploader {
        let auth: Authorization
        if let account = account {
            auth = .bearerToken(account.accessToken)
        } else {
            auth = .clientId(clientId)
        }
        return ImageUploaderMainThreadDecorator(
            decoratee: ImgurUploader(
                client: httpClient,
                auth: auth,
                builder: MultipartFormBuilder()
            )
        )
    }
}
