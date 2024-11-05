//
//  ExtensionForArray.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 05.11.2024.
//

import Foundation

extension Array where Element == WeekDay {
    func toString() -> String {
        return self.map { $0.rawValue }.joined(separator: ",")
    }
}
