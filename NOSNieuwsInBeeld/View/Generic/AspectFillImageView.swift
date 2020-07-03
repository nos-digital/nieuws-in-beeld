//
//  AspectFillImageView.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


/// An image view that scales its image to fill its bounds while
/// respecing the image's aspect ratio.
///
class AspectFillImageView: NSView
{
    var image: NSImage? {
        didSet {
            layer?.contents = image
        }
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer?.contentsGravity = .resizeAspectFill
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
