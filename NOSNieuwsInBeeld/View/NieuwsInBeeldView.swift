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
    private let imageLoader: ImageLoading = ImageDownloader()
    
    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        
        setup()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup()
    {
        wantsLayer = true
        
        animationTimeInterval = 1.0 / 30.0
        
        loadPhotos()
        setupSubviews()
        
        #if APP
        startCustomTimer()
        #endif
    }
    
    deinit
    {
        #if APP
        slideTimer?.invalidate()
        #endif
    }
    
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
    
    private func preloadPhoto(at index: Int)
    {
        loadViewModel(at: index) { [weak self] result in
            guard let self = self else { return }
            
            switch result
            {
                case .success(let viewModel):
                    DispatchQueue.main.async { self.nextSlide.viewModel = viewModel }
                
                case .failure:
                    break // ignore for now
            }
        }
    }
    
    private func loadViewModel(at index: Int, completion: @escaping (Result<SlideViewModel, Error>) -> Void)
    {
        guard 0..<photos.count ~= index else { return }

        let photo = photos[index]
        
        guard let url = photo.formats.last?.url.jpg else { return }
        
        imageLoader.loadImage(from: url) { result in
            switch result
            {
                case .success(let image):
                    let viewModel = SlideViewModel(image: image,
                                                                 title: photo.title,
                                                                 description: photo.description,
                                                                 copyright: photo.copyright)
                    
                    completion(.success(viewModel))
                
                case .failure(let error):
                    completion(.failure(error))
            }
        }
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
    
    // MARK: Slideshow
    
    private let slideDuration: TimeInterval = 10
    private let crossFadeDuration: TimeInterval = 1
    
    private func showPhoto(at index: Int)
    {
        guard 0..<photos.count ~= index else { return }
        
        photoIndex = index
        
        if currentSlide.viewModel == nil
        {
            showInitialSlide()
        }
        else
        {
            showNextSlide()
        }
    }
    
    private func showInitialSlide()
    {
        currentSlide.isHidden = true
        
        loadViewModel(at: 0) { [weak self] result in
            guard let self = self else { return }
        
            DispatchQueue.main.async {
                switch result
                {
                    case .success(let viewModel):
                        self.currentSlide.viewModel = viewModel
                        
                        self.currentSlide.animateImage(duration: self.slideDuration + self.crossFadeDuration)
                        NSAnimationContext.runAnimationGroup { context in
                            context.duration = self.crossFadeDuration
                            
                            self.currentSlide.isHidden = false
                        }
                        
                        self.preloadPhoto(at: self.nextPhotoIndex)
                    
                    case .failure:
                        break // ignore for now
                }
            }
        }
    }
    
    private func showNextSlide()
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
    
    // MARK: ScreenSaver overrides
    
    private var timeElapsed: TimeInterval = 0
    override func animateOneFrame()
    {
        timeElapsed += animationTimeInterval
        
        if timeElapsed >= slideDuration
        {
            showPhoto(at: nextPhotoIndex)
            timeElapsed = 0
        }
    }
    
    #if APP
    private var slideTimer: Timer?
    private func startCustomTimer()
    {
        slideTimer = Timer.scheduledTimer(withTimeInterval: slideDuration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.showPhoto(at: self.nextPhotoIndex)
        })
    }
    #endif
    
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
