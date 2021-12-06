//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let terminateLauncher = Notification.Name("terminateLauncher")
}

@main
class AppDelegate: NSObject {
    @objc func terminate() {
        NSApp.terminate(nil)
    }
}
                   
extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainBundleIdentifier = "com.ailinykh.ImgurBar"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainBundleIdentifier }.isEmpty

        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: .terminateLauncher, object: mainBundleIdentifier)

            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            NSWorkspace.shared.launchApplication(path as String)
        }
        else {
            self.terminate()
        }
    }
}

