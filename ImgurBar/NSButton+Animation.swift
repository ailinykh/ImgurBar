//
//  NSButton+Animation.swift
//  imgurBar
//
//  Created by Anton Ilinykh on 12.04.2020.
//  Copyright © 2020 Anton Ilinykh. All rights reserved.
//

import Cocoa

extension NSButton {
    func startAnimation() {
        image = NSImage(named: "animation01")
        processAnimation()
    }
    
    func processAnimation() {
        guard
            let current = image?.name(),
            let n = Int(current.suffix(2))
        else {
            return
        }
        
        let images = [
            "animation01",
            "animation02",
            "animation03",
            "animation04",
            "animation05"
        ]
        
        let name = String(format: "animation%02d", n % images.count + 1)
        image = NSImage(named: name)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.processAnimation()
        }
    }
    
    func stopAnimation() {
        image = NSImage(named: "status_item")
    }
}
