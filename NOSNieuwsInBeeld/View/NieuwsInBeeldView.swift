//
//  NieuwsInBeeldView.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 29/06/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import ScreenSaver

class NieuwsInBeeldView: ScreenSaverView
{
    private let api: APIClient = NOSAPIClient()
    
    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        
        animationTimeInterval = 1.0 / 30.0
        
        loadPhotos()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Data
    
    private lazy var photos: [Photo] = []
    
    private func loadPhotos()
    {
        api.loadPhotos { [weak self] result in
            switch result
            {
                case .success(let photos): self?.updatePhotos(photos)
                case .failure: break // ignore for now
            }
        }
    }
    
    private func updatePhotos(_ photos: [Photo])
    {
        self.photos = photos
    }
    
    // MARK: Animations
    
    override func startAnimation()
    {
        super.startAnimation()
    }
    
    override func stopAnimation()
    {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
    }
    
    override func animateOneFrame()
    {
        
    }
    
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
