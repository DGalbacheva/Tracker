//
//  Tracker.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 23.08.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let date: Date
    let emoji: String
    let title: String
    let color: UIColor
    let dayCount: Int
    let schedule: [WeekDay]?
}
