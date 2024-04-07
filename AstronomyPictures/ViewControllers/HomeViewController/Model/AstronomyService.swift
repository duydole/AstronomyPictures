//
//  AstronomyService.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation

protocol AstronomyServiceProtocol {
    func fetchAllAstronomyEntity(from fromDate: Date, to toDate: Date) async throws -> [AstronomyEntity]
}

enum AstronomyServiceError: Error {
    case invalidURL
    case networkError(error: Error)
    case decodingError(error: Error)
    case unknownError
}

class AstronomyService: AstronomyServiceProtocol {
    
    private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        return URLSession(configuration: configuration)
    }()

    func fetchAllAstronomyEntity(from fromDate: Date, to toDate: Date) async throws -> [AstronomyEntity] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDateStr = dateFormatter.string(from: fromDate)
        let endDateStr = dateFormatter.string(from: toDate)
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&start_date=\(fromDateStr)&end_date=\(endDateStr)"
        
        guard let url = URL(string: urlString) else {
            throw AstronomyServiceError.invalidURL
        }

        do {
            
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let entities = try decoder.decode([AstronomyEntity].self, from: data)
            return entities
        } 
        catch {
            if let decodingError = error as? DecodingError {
                throw AstronomyServiceError.decodingError(error: decodingError)
            }
            else {
                throw AstronomyServiceError.networkError(error: error)
            }
        }
    }
}
