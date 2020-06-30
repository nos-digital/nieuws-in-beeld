//
//  SlideView.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 29/06/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import ScreenSaver


struct SlideViewModel
{
    var image: URL
}

private class ImageView: NSView
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
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SlideView: NSView
{
    var onImageLoaded: (() -> Void)?
    
    var viewModel: SlideViewModel? {
        didSet {
            imageView.image = nil
            loadImage()
        }
    }
    var api: APIClient
    
    init(api: APIClient = NOSAPIClient())
    {
        self.api = api
        
        super.init(frame: .zero)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    // MARK: Data
    

    private func loadImage()
    {
        guard let url = viewModel?.image else { return }
        
        api.loadImage(with: url) { [weak self] result in
            switch result
            {
                case .success(let image): DispatchQueue.main.async { self?.imageView.image = image; self?.onImageLoaded?() }
                case .failure: break // ignore for now
            }
        }
    }
    
    
    // MARK: Subviews
    
    private let imageView = ImageView()
    
    private func setupSubviews()
    {
        layer = CALayer()
        
        addSubview(imageView)
    }
    
    // MARK: Animation
    
    private let scaleRatio: CGFloat = 1.04
    private let zoomRatio: CGFloat = 1.06

    func animateImage(duration: TimeInterval)
    {
        var origin: CGPoint
        var zoom: CGPoint
        var move: CGPoint

        let size = bounds.size
        let optimus = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)

        // Calculate the maximum move allowed
        let maxMoveX = optimus.width - size.width
        let maxMoveY = optimus.height - size.height
        let moveType = Int.random(in: 0...3)

        switch moveType
        {
            case 0:
                origin = .zero
                zoom = CGPoint(x: zoomRatio, y: zoomRatio)
                move = CGPoint(x: -maxMoveX, y: -maxMoveY)

            case 1:
                origin = CGPoint(x: 0, y: size.height - optimus.height)
                zoom = CGPoint(x: zoomRatio, y: zoomRatio)
                move = CGPoint(x: -maxMoveX, y: maxMoveY)

            case 2:
                origin = CGPoint(x: size.width - optimus.width, y: 0)
                zoom = CGPoint(x: zoomRatio, y: zoomRatio)
                move = CGPoint(x: maxMoveX, y: -maxMoveY)

            case 3:
                origin = CGPoint(x: size.width - optimus.width, y: size.height - optimus.height)
                zoom = CGPoint(x: zoomRatio, y: zoomRatio)
                move = CGPoint(x: maxMoveX, y: maxMoveY)

            default:
                origin = .zero
                zoom = CGPoint(x: 1, y: 1)
                move = CGPoint(x: -maxMoveX, y: -maxMoveY)
        }

        let moveRight = CGAffineTransform(translationX: move.x, y: move.y)
        let zoomIn = CGAffineTransform(scaleX: zoom.x, y: zoom.y)
        let transform = zoomIn.concatenating(moveRight)

        let zoomedTransform = transform
        let standardTransform = CGAffineTransform.identity

        let startTransform: CATransform3D
        let finishTransform: CATransform3D

        if Int.random(in: 0...1) == 0 {
            startTransform = CATransform3DMakeAffineTransform(standardTransform)
            finishTransform = CATransform3DMakeAffineTransform(zoomedTransform)
        } else {
            startTransform = CATransform3DMakeAffineTransform(zoomedTransform)
            finishTransform = CATransform3DMakeAffineTransform(standardTransform)
        }
        
        imageView.frame = CGRect(origin: origin, size: optimus)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = duration + 2
        animation.fillMode = .forwards
        animation.timingFunction = .init(name: .linear)
        animation.fromValue = startTransform
        animation.toValue = finishTransform
        animation.isRemovedOnCompletion = true
        imageView.layer?.add(animation, forKey: "pan")
    }
}
