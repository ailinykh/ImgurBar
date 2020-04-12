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

    let imagePublisher = PassthroughSubject<Data, Never>()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        registerForDraggedTypes([.fileContents, .fileURL])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        
        if
            NSImage.canInit(with: pboard),
            let image = NSImage(pasteboard: pboard),
            let data = image.tiffRepresentation
        {
            imagePublisher.send(data)
            return true
        }
        
        return false
    }
}
