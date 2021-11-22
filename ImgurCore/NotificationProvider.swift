//
//  NotificationProvider.swift
//  ImgurCore
//
//  Created by Anton Ilinykh on 22.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public protocol NotificationProvider {
    func sendNotification(identifier: String, title: String, text: String)
}
