//
//  ImageDownloaderManager.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

enum ImageDownloaderError: Error {
    case invalidImageData
    case networkError(error: Error)
    case unknownError
}

protocol ImageDownloaderProtocol {
    func downloadImage(url: URL) async throws -> UIImage?
}

class ImageDownloader: ImageDownloaderProtocol {
    
    func downloadImage(url: URL) async throws -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageDownloaderError.invalidImageData
            }
            return image
        } 
        catch {
            if let urlError = error as? URLError {
                throw ImageDownloaderError.networkError(error: urlError)
            } else {
                throw ImageDownloaderError.unknownError
            }
        }
    }
}
