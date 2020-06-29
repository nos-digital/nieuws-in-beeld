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
        setupSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Data
    
    private lazy var photos: [Photo] = []
    private var photoIndex = 0
    
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
        showPhoto(at: photoIndex)
    }
    
    private func showPhoto(at index: Int)
    {
        guard 0..<photos.count ~= index else { return }
        
        slideView.viewModel = SlideViewModel(image: photos[index].formats.last!.url.jpg)
    }
    
    // MARK: Subviews
    
    private lazy var slideView = SlideView(viewModel: nil, api: api)
    
    private func setupSubviews()
    {
        slideView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slideView)
        
        NSLayoutConstraint.activate([
            slideView.topAnchor.constraint(equalTo: topAnchor),
            slideView.bottomAnchor.constraint(equalTo: bottomAnchor),
            slideView.leftAnchor.constraint(equalTo: leftAnchor),
            slideView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
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
    
    private var timeElapsed: TimeInterval = 0
    override func animateOneFrame()
    {
        timeElapsed += animationTimeInterval
        
        if timeElapsed >= 2
        {
            photoIndex = min(photos.count - 1, max(0, photoIndex + 1))
            showPhoto(at: photoIndex)
            timeElapsed = 0
        }
        
        setNeedsDisplay(bounds)
    }
    
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
