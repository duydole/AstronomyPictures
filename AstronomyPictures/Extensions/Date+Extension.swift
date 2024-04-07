//
//  Date+Extension.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation

extension Date {
    
    func dateBySubtracting(days: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = -days
        return Calendar.current.date(byAdding: dateComponent, to: self)!
    }
}
