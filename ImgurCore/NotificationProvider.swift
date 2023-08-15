//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation

public extension String {
    static let imageUploadCompleted = "com.ailinykh.imgurbar.image_upload_completed"
}

public protocol NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String)
}
