//
//  AstronomyListViewModel.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation

fileprivate let previousDayCount = 7

class AstronomyListViewModel {
    
    // MARK: - Properties
    
    private let lastFetchRequestKey = "LastFetchRequestDate"
    let astronomyModel = AstronomyService()
    let entityCache = AstronomyEntityCacheManager.shared

    var isLoading: Bool = false {
        didSet {
            showLoadingIndicator?(isLoading)
        }
    }
        
    var items: [AstronomyCellViewModel] = [] {
        didSet {
            didUpdateListItems?()
        }
    }
    
    private var showEmpty: Bool = false {
        didSet {
            showEmptyView?(showEmpty)
        }
    }

    var didUpdateListItems: (() -> Void)?
    var showAlertClosure: ((String) -> Void)?
    var showLoadingIndicator: ((Bool) -> Void)?
    var showEmptyView: ((Bool) -> Void)?

    // MARK: - Fetching Data
    
    func loadAstronomyEntitiesFromCache() {
        let currDate = Date()
        let startDate = Date().dateBySubtracting(days: previousDayCount)
        guard let entities = entityCache.entities(fromDate: startDate, toDate: currDate) else {
            return
        }
        items = entities.reversed().map { AstronomyCellViewModel(entity: $0) }
    }
    
    func fetchAstronomyEntities() async {
        guard shouldFetchNewData() else { return }

        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let currDate = Date()
            let startDate = Date().dateBySubtracting(days: previousDayCount)
            let entities = try await astronomyModel.fetchAllAstronomyEntity(from: startDate, to: currDate)
            entityCache.cacheEntities(entities)
            items = entities.reversed().map { AstronomyCellViewModel(entity: $0) }
            showEmpty = false
            updateLastFetchRequestDate()
        }
        catch AstronomyServiceError.decodingError(let error),
              AstronomyServiceError.networkError(let error) {
            showAlertClosure?(error.localizedDescription)
            showEmpty = items.isEmpty
        }
        catch {
            showAlertClosure?(error.localizedDescription)
            showEmpty = items.isEmpty
        }
    }

    // MARK: - Actions
    
    func didTapRetryButton() {
        Task {
            await fetchAstronomyEntities()
        }
    }
    
    // MARK: - Private
    
    private func shouldFetchNewData() -> Bool {
        let calendar = Calendar.current
        let lastFetchDate = UserDefaults.standard.object(forKey: lastFetchRequestKey) as? Date
        return lastFetchDate == nil || !calendar.isDateInToday(lastFetchDate!)
    }

    private func updateLastFetchRequestDate() {
        UserDefaults.standard.set(Date(), forKey: lastFetchRequestKey)
    }
}
