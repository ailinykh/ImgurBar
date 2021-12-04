//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public protocol NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String)
}
