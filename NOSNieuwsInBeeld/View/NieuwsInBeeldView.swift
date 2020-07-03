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
    private let slideDuration: TimeInterval = 10
    private let crossFadeDuration: TimeInterval = 1
    
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
    private var nextPhotoIndex: Int { 0..<photos.count ~= photoIndex + 1 ? photoIndex + 1 : 0 }
    
    private func loadPhotos()
    {
        api.loadPhotos { [weak self] result in
            switch result
            {
                case .success(let photos): DispatchQueue.main.async { self?.updatePhotos(photos) }
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
            currentSlide.viewModel = SlideViewModel(photo: photos[index])
            currentSlide.isHidden = true
            currentSlide.onImageLoaded = { [weak self] in
                guard let self = self else { return }
                
                self.currentSlide.onImageLoaded = nil
                self.currentSlide.animateImage(duration: self.slideDuration + self.crossFadeDuration)
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = self.crossFadeDuration
                    
                    self.currentSlide.isHidden = false
                }
                
                self.preloadPhoto(at: self.nextPhotoIndex)
            }
        }
        else
        {
            nextSlide.animateImage(duration: slideDuration + crossFadeDuration)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = crossFadeDuration
                
                currentSlide.alphaValue = 0
                nextSlide.isHidden = false
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
        nextSlide.viewModel = SlideViewModel(photo: photos[index])
    }
    
    // MARK: Subviews
    
    private lazy var currentSlide = SlideView(api: api)
    private lazy var nextSlide = SlideView(api: api)

    private func setupSubviews()
    {
        [currentSlide, nextSlide].forEach { addSubview($0) }
        nextSlide.isHidden = true
    }
    
    override func layout() {
        super.layout()
        [currentSlide, nextSlide].forEach { $0.frame = bounds }
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
