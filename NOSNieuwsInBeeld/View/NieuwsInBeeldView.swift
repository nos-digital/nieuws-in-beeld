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
    private let slideDuration: TimeInterval = 2
    
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
        photoIndex = 0
        showPhoto(at: photoIndex)
    }
    
    private func showPhoto(at index: Int)
    {
        guard 0..<photos.count ~= index else { return }
        
        let viewModel = SlideViewModel(image: photos[index].formats.last!.url.jpg)
        
        if currentSlideView.viewModel == nil
        {
            currentSlideView.viewModel = viewModel
        }
        else
        {
            nextSlideView.viewModel = viewModel
            
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 1
                
            currentSlideView.animator().isHidden = true
            nextSlideView.animator().isHidden = false
            
            NSAnimationContext.current.completionHandler = {
                let current = self.currentSlideView
                self.currentSlideView = self.nextSlideView
                self.nextSlideView = current
            }
            NSAnimationContext.endGrouping()
            
        }
    }
    
    // MARK: Subviews
    
    private lazy var currentSlideView = SlideView(viewModel: nil, api: api)
    private lazy var nextSlideView = SlideView(viewModel: nil, api: api)

    private func setupSubviews()
    {
        var constraints: [NSLayoutConstraint] = []
        
        [currentSlideView, nextSlideView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            
            constraints.append(contentsOf: [
                $0.topAnchor.constraint(equalTo: topAnchor),
                $0.bottomAnchor.constraint(equalTo: bottomAnchor),
                $0.leftAnchor.constraint(equalTo: leftAnchor),
                $0.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
        
        nextSlideView.isHidden = true
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
        
        if timeElapsed >= slideDuration
        {
            advancePhotoIndex()
            showPhoto(at: photoIndex)
            timeElapsed = 0
        }
        
        setNeedsDisplay(bounds)
    }
    
    private func advancePhotoIndex()
    {
        photoIndex = min(photos.count - 1, max(0, photoIndex + 1))
    }
    
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
