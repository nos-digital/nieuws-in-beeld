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
    var title: String
    var description: String
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

private class GradientView: NSView
{
    let gradientLayer = CAGradientLayer()
    
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

class SlideView: NSView
{
    var onImageLoaded: (() -> Void)?
    
    var viewModel: SlideViewModel? {
        didSet {
            imageView.image = nil
            if let viewModel = viewModel
            {
                loadImage()
                
                titleLabel.stringValue = viewModel.title
                descriptionLabel.stringValue = viewModel.description
                
                needsLayout = true
            }
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
    
    private let textShadow: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowColor = .black
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = NSSize(width: 0, height: 1)
        return shadow
    }()
    private lazy var titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.alignment = .center
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = .max
        label.shadow = textShadow
        return label
    }()
    
    private lazy var descriptionLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        label.alignment = .center
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = .max
        label.shadow = textShadow
        return label
    }()
    
    private let gradient: GradientView = {
        let gradient = GradientView(frame: .zero)
        gradient.locations = [0, 1]
        gradient.colors = [NSColor.black.withAlphaComponent(0.5), NSColor.black.withAlphaComponent(0)]
        return gradient
    }()
    
    private func setupSubviews()
    {
        layer = CALayer()
        
        [imageView, gradient, titleLabel, descriptionLabel].forEach { addSubview($0) }
    }
    
    private let insets = NSEdgeInsets(top: 0, left: 100, bottom: 100, right: 100)
    private let titleDescriptionMargin: CGFloat = 32
    
    override func layout()
    {
        super.layout()
        
        var availableSize = bounds.size
        availableSize.width -= insets.left + insets.right
        availableSize.width = min(availableSize.width, 800)
        
        let titleSize = titleLabel.sizeThatFits(availableSize)
        let descriptionSize = descriptionLabel.sizeThatFits(availableSize)
        
        var origin = CGPoint(x: (bounds.size.width - availableSize.width) / 2,
                             y: insets.bottom + descriptionSize.height)
        
        descriptionLabel.frame = CGRect(x: origin.x, y: origin.y, width: availableSize.width, height: descriptionSize.height)
        origin.y += titleDescriptionMargin + titleSize.height
        
        titleLabel.frame = CGRect(x: origin.x, y: origin.y, width: availableSize.width, height: titleSize.height)
        
        gradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: origin.y + 100)
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
