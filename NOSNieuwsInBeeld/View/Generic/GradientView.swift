//
//  GradientView.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


/// A view that uses a `CAGradientLayer` to render a gradient.
/// The gradient can be configured using the view's `colors` and `locations` properties.
///
class GradientView: NSView
{
    var colors: [NSColor] = [] {
        didSet {
            gradientLayer.colors = colors.map { $0.cgColor }
        }
    }
    
    var locations: [NSNumber] = [] {
        didSet {
            gradientLayer.locations = locations
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layer = gradientLayer
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layout()
    {
        super.layout()
        
        gradientLayer.frame = bounds
    }
}
