//
//  InsetLabel.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


/// Wraps an NSTextField configured as a label and adds optional
/// insets around it.
///
class InsetLabel: NSView
{
    var insets: NSDirectionalEdgeInsets = .init() {
        didSet {
            labelLeadingConstraint.constant = insets.leading
            labelTrailingConstraint.constant = -insets.trailing
            labelTopConstraint.constant = insets.top
            labelBottomConstraint.constant = -insets.bottom
        }
    }
    
    private let label = NSTextField(labelWithString: "")

    private lazy var labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
    private lazy var labelTrailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
    private lazy var labelTopConstraint = label.topAnchor.constraint(equalTo: topAnchor)
    private lazy var labelBottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            labelLeadingConstraint, labelTrailingConstraint,
            labelTopConstraint, labelBottomConstraint
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// MARK: - Wrapped properties


extension InsetLabel
{
    var stringValue: String {
        get { label.stringValue }
        set { label.stringValue = newValue }
    }
    
    var textColor: NSColor? {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    var font: NSFont? {
        get { label.font }
        set { label.font = newValue }
    }
    
    var alignment: NSTextAlignment {
        get { label.alignment }
        set { label.alignment = newValue }
    }
}
