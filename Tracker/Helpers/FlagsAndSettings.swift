//
//  FlagsAndSettings.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import Foundation

final class FlagsAndSettings {
    let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
}
