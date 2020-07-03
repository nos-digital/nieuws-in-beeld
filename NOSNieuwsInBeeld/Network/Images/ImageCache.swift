//
//  ImageCache.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


struct ImageCache
{
    init()
    {
        setupCache()
    }
    
    private func setupCache()
    {
        guard let url = cacheLocation else { return }
        
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        clearOldItemsIfNeeded()
    }
    
    // MARK: Public methods
    
    func hasCachedImage(for url: URL) -> Bool
    {
        guard let location = location(of: filename(for: url)) else { return false }
        
        return FileManager.default.fileExists(atPath: location.path)
    }
    
    func cachedImage(for url: URL) -> NSImage?
    {
        guard let location = location(of: filename(for: url)) else { return nil }
        
        return NSImage(contentsOf: location)
    }
    
    @discardableResult
    func cacheImage(_ image: NSImage, with url: URL) -> Bool
    {
        guard let location = location(of: filename(for: url)) else { return false }
        guard let data = image.tiffRepresentation else { return false }
        
        return FileManager.default.createFile(atPath: location.path, contents: data, attributes: nil)
    }
    
    enum TestError: Error
    {
        case fuck(String, Error)
    }
    
    // MARK: Helpers
    
    private var cacheLocation: URL? = {
        let localCachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        return localCachePaths.first?.appendingPathComponent("NOSNieuwsInBeeld").appendingPathComponent("Images")
    }()
    
    private func filename(for url: URL) -> String
    {
        return "\(url.path.replacingOccurrences(of: "/", with: "-"))"
    }
    
    private func location(of file: String) -> URL?
    {
        cacheLocation?.appendingPathComponent(file)
    }
    
    private func clearOldItemsIfNeeded()
    {
        let maxItemCount = 15
        
        guard let location = cacheLocation,
            var urls = try? FileManager.default.contentsOfDirectory(at: location, includingPropertiesForKeys: [.creationDateKey, .contentAccessDateKey], options: []),
            urls.count >= maxItemCount
            else { return }
        
        urls.sort { (left, right) in
            guard let date1 = try? left.resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate,
                let date2 = try? right.resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate
                else {
                    return false
            }
            
            return date1 < date2
        }
        
        urls.removeLast(maxItemCount)
        
        urls.forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }
}
