//
//  AstronomyCellViewModel.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

class AstronomyCellViewModel: Hashable {
    
    let title: String
    let date: String
    let explanation: String
    let imageUrl: URL?
    let urlKey: String
    let imageDownloader = ImageDownloader()
    
    var didUpdateImage: ((String) -> Void)?

    var image: UIImage? {
        didSet {
            didUpdateImage?(urlKey)
        }
    }
    
    init(entity: AstronomyEntity) {
        self.title = entity.title
        self.date = entity.date
        self.imageUrl = entity.imageURL
        self.urlKey = entity.urlKey
        self.explanation = entity.explanation
    }
    
    func fetchImage() {
        
        // Check Memory
        if let image = ImageMemoryCacheManager.shared.image(forKey: urlKey) {
            self.image = image
            return
        }
        
        // Check Disk
        if let image = ImageDiskCacheManager.shared.loadImage(fileName: urlKey) {
            ImageMemoryCacheManager.shared.setImage(image, forKey: urlKey)
            self.image = image
            return
        }
        
        guard let imageUrl = imageUrl else {
            return
    	}
        
        Task {
            let image = try? await imageDownloader.downloadImage(url: imageUrl)
            if let image = image {
                self.image = image
                ImageMemoryCacheManager.shared.setImage(image, forKey: urlKey)
                ImageDiskCacheManager.shared.saveImage(image, fileName: urlKey)
            }
        }

    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(date)
        hasher.combine(urlKey)
        //hasher.combine(explanation)
    }

    static func == (lhs: AstronomyCellViewModel, rhs: AstronomyCellViewModel) -> Bool {
        lhs.title == rhs.title && lhs.date == rhs.date && lhs.urlKey == rhs.urlKey
    }
}
