//
//  ScreenshotsObserver.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 11.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Foundation
import Combine

class ScreenshotsObserver: NSObject {
    let screenshotsPubliser = PassthroughSubject<Data, Never>()
    
    private let query: NSMetadataQuery
    private var subscriptions = Set<AnyCancellable>()
    
    override init() {
        query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        
        let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        
        // trigger Desktop folder access request
        _ = try? FileManager.default.contentsOfDirectory(atPath: url.path)
        
        query.searchScopes = [url]
        
        super.init()
        
//        NSFileCoordinator.addFilePresenter(self)
        
        NotificationCenter.default.publisher(for: .NSMetadataQueryDidUpdate)
            .compactMap { $0.userInfo?[kMDQueryUpdateChangedItems] as? [NSMetadataItem] }
            .map { $0.publisher }
            .switchToLatest()
            .compactMap { $0.value(forAttribute: kMDItemFSName as String) as? String }
            .map { url.appendingPathComponent($0) }
            .compactMap { FileManager.default.contents(atPath: $0.path) }
            .sink(receiveValue: { [unowned self] in
                self.screenshotsPubliser.send($0)
            })
            .store(in: &subscriptions)
        
        query.start()
    }
    
    deinit {
        query.stop()
    }
}

// NSFilePresenter extension
/*
extension ScreenshotsObserver: NSFilePresenter {
    var presentedItemURL: URL? {
        let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        
        if let path = url?.path {
            // trigger Desktop folder access request 
            _ = try? FileManager.default.contentsOfDirectory(atPath: path)
        }
        
        return url
    }
    
    var presentedItemOperationQueue: OperationQueue {
        if let queue = OperationQueue.current {
            return queue
        }
        return OperationQueue.main
    }
    
    func presentedSubitemDidAppear(at url: URL) {
        print(#function, url)
    }
    
    func presentedSubitemDidChange(at url: URL) {
        print(#function, url)
        filePubliser.send(url)
    }
}
*/
