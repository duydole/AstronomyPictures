//
//  AstronomyEntityCacheManager.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 7/4/24.
//

import Foundation

protocol AstronomyEntityCacheProtocol {
    func cacheEntities(_ entities: [AstronomyEntity])
    func entities(fromDate: Date, toDate: Date) -> [AstronomyEntity]?
}

class AstronomyEntityCacheManager: AstronomyEntityCacheProtocol {
    
    public static let shared = AstronomyEntityCacheManager()
    public static var maxDayInCache = 10
    
    private let cacheFileName = "astronomyEntitiesCache.json"
    private var cache: [String: [String: AstronomyEntity]] = [:]
    
    private init() {
        loadCacheFromDisk()
    }
    
    // MARK: - AstronomyEntityCacheProtocol
    
    func cacheEntities(_ entities: [AstronomyEntity]) {
        entities.forEach { entity in
            let key = entity.date
            cache[key, default: [:]][entity.urlKey] = entity
        }
        saveCacheToDisk()
    }
    
    func entitiesForDate(_ date: Date) -> [AstronomyEntity]? {
        let key = cacheKey(for: date)
        guard let values = cache[key], !values.isEmpty else {
            return nil
        }
        return Array(values.values)
    }

    func entities(fromDate: Date, toDate: Date) -> [AstronomyEntity]? {
        var allEntities: [AstronomyEntity] = []
        var currentDate = fromDate
        
        let calendar = Calendar.current
        while currentDate <= toDate {
            if let entitiesForCurrentDate = entitiesForDate(currentDate) {
                allEntities.append(contentsOf: entitiesForCurrentDate)
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return allEntities.isEmpty ? nil : allEntities
    }
    
    // MARK: - Private Methods
    
    private func cacheKey(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    private func saveCacheToDisk() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cache)
            let url = try cacheFileURL()
            try data.write(to: url)
        } catch {
            print("Error saving cache to disk: \(error)")
        }
    }
    
    private func loadCacheFromDisk() {
        do {
            // Load cache
            let url = try cacheFileURL()
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedCache = try decoder.decode([String: [String: AstronomyEntity]].self, from: data)
            
            // Trim
            let sortedKeys = loadedCache.keys.sorted().suffix(AstronomyEntityCacheManager.maxDayInCache)
            var trimmedCache: [String: [String: AstronomyEntity]] = [:]
            sortedKeys.forEach { key in
                trimmedCache[key] = loadedCache[key]
            }

            self.cache = trimmedCache
			
            if self.cache.count != loadedCache.count {
                saveCacheToDisk()
            }
        } catch {
            print("Error loading cache from disk: \(error)")
        }
    }

    private func cacheFileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(cacheFileName)
    }
}
