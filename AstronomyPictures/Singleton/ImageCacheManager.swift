//
//  ImageMemoryCacheManager.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

class ImageMemoryCacheManager {
    static let shared = ImageMemoryCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 20 * 1024 * 1024 // bytes
    private let queue = DispatchQueue(label: "com.duydl.ImageMemoryCacheManager")
    
    private init() {
        cache.totalCostLimit = maxCacheSize
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        queue.async { [unowned self] in
            let cost = image.pngData()?.count ?? 0
            cache.setObject(image, forKey: key as NSString, cost: cost)
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        var image: UIImage?
        queue.sync {
            image = cache.object(forKey: key as NSString)
        }
        return image
    }
}
