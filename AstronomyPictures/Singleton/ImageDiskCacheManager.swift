//
//  ImageDiskCacheManager.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

class ImageDiskCacheManager {
    
    static let shared = ImageDiskCacheManager()
    
    private init() {}
    
    func saveImage(_ image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        let fileURL = self.fileURL(for: fileName)
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving image to disk: \(error.localizedDescription)")
        }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = self.fileURL(for: fileName)
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        
        return UIImage(data: imageData)
    }
    
    // MARK: Prive
    
    private func fileURL(for fileName: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    }
}
