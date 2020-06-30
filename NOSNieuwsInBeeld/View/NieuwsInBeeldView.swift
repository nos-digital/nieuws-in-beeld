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
    private let slideDuration: TimeInterval = 5
    private let crossFadeDuration: TimeInterval = 0.3
    
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
    private var nextPhotoIndex: Int { min(photos.count - 1, max(0, photoIndex + 1)) }
    
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
        
        photoIndex = index
        
        if currentSlide.viewModel == nil
        {
            currentSlide.viewModel = SlideViewModel(image: photos[index].formats.last!.url.jpg)
            preloadPhoto(at: nextPhotoIndex)
        }
        else
        {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = self.crossFadeDuration
                
                self.currentSlide.alphaValue = 0
                self.nextSlide.isHidden = false
            },
                                                 completionHandler: {
                                                    let current = self.currentSlide
                                                    let next = self.nextSlide
                                                    
                                                    current.isHidden = true
                                                    current.alphaValue = 1
                                                    
                                                    self.currentSlide = next
                                                    self.nextSlide = current
                                                    self.preloadPhoto(at: self.nextPhotoIndex)
            })
        }
    }
    
    private func preloadPhoto(at index: Int)
    {
        guard 0..<photos.count ~= index else { return }
        nextSlide.viewModel = SlideViewModel(image: photos[index].formats.last!.url.jpg)
    }
    
    // MARK: Subviews
    
    private lazy var currentSlide = SlideView(api: api)
    private lazy var nextSlide = SlideView(api: api)

    private func setupSubviews()
    {
        var constraints: [NSLayoutConstraint] = []

        [currentSlide, nextSlide].forEach {
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
        
        nextSlide.isHidden = true
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
            showPhoto(at: nextPhotoIndex)
            timeElapsed = 0
        }
        
        setNeedsDisplay(bounds)
    }
    
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
