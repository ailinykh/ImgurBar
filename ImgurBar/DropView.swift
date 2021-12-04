//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Cocoa
import ImgurCore

class DropView: NSView {
    
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
                consumers.forEach {
                    $0.consume(image: LocalImage(fileUrl: url))
                }
                rv = true
            }
        }
        return rv
    }
    
    private var consumers = [LocalImageConsumer]()
}

extension DropView: LocalImageProvider {
    func add(consumer: LocalImageConsumer) {
        consumers.append(consumer)
    }
}
