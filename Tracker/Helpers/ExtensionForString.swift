//
//  ExtensionForString.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 05.11.2024.
//

import Foundation

extension String {
    func toWeekdaysArray() -> [WeekDay] {
        return self.split(separator: ",").compactMap { WeekDay(rawValue: String($0)) }
    }
}
