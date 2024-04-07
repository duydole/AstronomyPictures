//
//  AstronomyEntity.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import CryptoKit

class AstronomyEntity: Codable {
    var date: String
    var explanation: String
    var hdurl: String?
    var mediaType: String
    var serviceVersion: String
    var title: String
    var url: String
    
    var urlKey: String {
        let data = Data(url.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    var imageURL: URL? {
        return URL(string: url)
    }
    
    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl, mediaType = "media_type", serviceVersion = "service_version", title, url
    }
    
    init(date: String, explanation: String, hdurl: String, mediaType: String, serviceVersion: String, title: String, url: String) {
        self.date = date
        self.explanation = explanation
        self.hdurl = hdurl
        self.mediaType = mediaType
        self.serviceVersion = serviceVersion
        self.title = title
        self.url = url
    }
}
