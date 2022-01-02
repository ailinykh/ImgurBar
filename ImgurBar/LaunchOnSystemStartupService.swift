//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation
import ServiceManagement

final class LaunchOnSystemStartupService {
    func get() -> Bool {
        guard let jobs = (LaunchOnSystemStartupService.self as DeprecationWarningWorkaround.Type).jobsDict else {
            return false
        }
        let job = jobs.first { ($0["Label"] as? String) == helperBundleIdentifier }
        return job?["OnDemand"] as? Bool ?? false
    }
    
    func set(value: Bool) {
        let bundleId = helperBundleIdentifier as CFString
        SMLoginItemSetEnabled(bundleId, value)
        print("LaunchOnSystemStartupSetting:", value)
    }
}

private protocol DeprecationWarningWorkaround {
    static var jobsDict: [[String: AnyObject]]? { get }
}

extension LaunchOnSystemStartupService: DeprecationWarningWorkaround {
    // Workaround to silence "'SMCopyAllJobDictionaries' was deprecated in OS X 10.10" warning
    @available(*, deprecated)
    static var jobsDict: [[String: AnyObject]]? {
        SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]]
    }
}
