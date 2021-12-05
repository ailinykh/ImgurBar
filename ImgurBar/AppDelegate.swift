//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import ImgurCore
import ServiceManagement

private final class LocalImageProviderFacade: LocalImageConsumer {
    let onImage: (LocalImage) -> Void
    
    init(onImage: @escaping (LocalImage) -> Void) {
        self.onImage = onImage
    }
    
    func consume(image localImage: LocalImage) {
        onImage(localImage)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var menu: NSMenu!
    
    private var statusBarItem: NSStatusItem?
    private let view = DropView(frame: .zero)
    
    private let helperBundleIdentifier = "com.ailinykh.ImgurBarHelper"
    
    private lazy var notificationProvider: NotificationProvider = {
        guard #available(macOS 10.14, *) else {
            return LegacyNotifiactionProvider()
        }
        return UserNotificationProvider()
    }()
    
    private lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: .main)
        let windowController = storyboard.instantiateInitialController() as! PreferencesWindowController
        
        if let tab = windowController.window?.contentViewController as? PreferencesTabViewController,
           let vc = tab.tabViewItems.first?.viewController as? GeneralPrefsViewController {
            vc.launchOnSystemStartup = getLaunchOnSystemStartupSetting()
            vc.onLaunchOnSystemStartupChanged = { [weak self] changed in
                guard let self = self else { return }
                let bundleId = self.helperBundleIdentifier as CFString
                SMLoginItemSetEnabled(bundleId, changed)
            }
        }
        
        return windowController
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        checkLaunchOnSystemStartup()
        setupStatusBar()
        
        guard let clientId = Bundle.main.infoDictionary?["imgur_client_id"] as? String else {
            preconditionFailure("Please retreive the `client_id` from https://api.imgur.com/oauth2/addclient and add it to Info.plist for key `imgur_client_id`")
        }
        
        let uploader = ImageUploaderMainThreadDecorator(decoratee: ImgurUploader(client: URLSession.shared, clientId: clientId, builder: MultipartFormBuilder()))
        
        let facade = LocalImageProviderFacade() { [weak self] localImage in
            self?.statusBarItem?.button?.startAnimation()
            
            uploader.upload(localImage) { result in
                switch (result) {
                case .success(let remoteImage):
                    self?.notificationProvider.sendNotification(identifier: "IMAGE_UPLOADED", title: "Image uploaded", text: remoteImage.url.absoluteString)
                case .failure(let error):
                    print(error)
                }
                self?.statusBarItem?.button?.stopAnimation()
            }
        }
        
        view.add(consumer: facade)
    }
    
    @IBAction func openPreferencesAction(_ sender: Any?) {
        preferencesWindowController.showWindow(sender)
        preferencesWindowController.window?.makeKeyAndOrderFront(sender)
    }
    
    // MARK: - private
    
    private func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem!.button?.image = NSImage(named: "status_item")
        statusBarItem!.menu = menu
        
        view.frame = statusBarItem?.button?.frame ?? .zero
        statusBarItem!.button?.addSubview(view)
    }
    
    private func checkLaunchOnSystemStartup() {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == helperBundleIdentifier }.isEmpty

        if isRunning {
            DistributedNotificationCenter.default().post(name: .terminateLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
    
    private func getLaunchOnSystemStartupSetting() -> Bool {
        guard let jobs = (AppDelegate.self as DeprecationWarningWorkaround.Type).jobsDict else {
            return false
        }
        let job = jobs.first { ($0["Label"] as? String) == helperBundleIdentifier }
        return job?["OnDemand"] as? Bool ?? false
    }
}

private protocol DeprecationWarningWorkaround {
    static var jobsDict: [[String: AnyObject]]? { get }
}

extension AppDelegate: DeprecationWarningWorkaround {
    // Workaround to silence "'SMCopyAllJobDictionaries' was deprecated in OS X 10.10" warning
    @available(*, deprecated)
    static var jobsDict: [[String: AnyObject]]? {
        SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]]
    }
}

extension Notification.Name {
    static let terminateLauncher = Notification.Name("terminateLauncher")
}
