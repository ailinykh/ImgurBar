//
//  DraggableView.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 12.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Cocoa
import Combine

class DraggableView: NSView {

    let imageDataPublisher = PassthroughSubject<Data, Never>()
    let imageUrlPublisher = PassthroughSubject<URL, Never>()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        registerForDraggedTypes([.fileContents, .fileURL])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if NSImage.canInit(with: sender.draggingPasteboard) {
            return .copy
        }
        return .private
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        var rv = false
        sender.draggingPasteboard.readObjects(forClasses: [NSURL.self])?.forEach {
            if let url = $0 as? URL {
                imageUrlPublisher.send(url)
                
                if let data = try? Data(contentsOf: url) {
                    imageDataPublisher.send(data)
                }
                
                rv = true
            }
        }
        return rv
    }
}
