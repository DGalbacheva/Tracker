//
//  ScheduleDelegate.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 23.08.2024.
//

import Foundation

protocol ScheduleDelegate: AnyObject {
    func weekDaysChanged(weedDays: [WeekDay])
}
