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

            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("ImgurBar")

            let newPath = NSString.path(withComponents: components)

            NSWorkspace.shared.launchApplication(newPath)
        }
        else {
            self.terminate()
        }
    }
}

