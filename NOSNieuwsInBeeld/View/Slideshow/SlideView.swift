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


class SlideView: NSView
{
    var viewModel: SlideViewModel? {
        didSet {
            imageView.image = nil
            loadImage()
        }
    }
    var api: APIClient
    
    init(viewModel: SlideViewModel?, api: APIClient = NOSAPIClient())
    {
        self.viewModel = viewModel
        self.api = api
        
        super.init(frame: .zero)
        
        setupSubviews()
        
        loadImage()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    // MARK: Data
    

    private func loadImage()
    {
        guard let url = viewModel?.image else { return }
        
        api.loadImage(with: url) { [weak self] result in
            switch result
            {
                case .success(let image): DispatchQueue.main.async { self?.imageView.image = image }
                case .failure: break // ignore for now
            }
        }
    }
    
    
    // MARK: Subviews
    
    private let imageView = NSImageView()
    
    private func setupSubviews()
    {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
