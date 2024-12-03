//
//  DataForHabit.swift
//  Tracker
//
//  Created by Doroteya Galbacheva 15 on 29.10.2024.
//

import UIKit

final class DataForHabitAndTracker {
    static let shared = DataForHabitAndTracker()
    
    private init() {}
    
    let emojis = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    let colors: [UIColor] = [UIColor(resource: .colorSet1), UIColor(resource: .colorSet2), UIColor(resource: .colorSet3), UIColor(resource: .colorSet4), UIColor(resource: .colorSet5), UIColor(resource: .colorSet6), UIColor(resource: .colorSet7), UIColor(resource: .colorSet8), UIColor(resource: .colorSet9), UIColor(resource: .colorSet10), UIColor(resource: .colorSet11), UIColor(resource: .colorSet12), UIColor(resource: .colorSet13), UIColor(resource: .colorSet14), UIColor(resource: .colorSet15), UIColor(resource: .colorSet16), UIColor(resource: .colorSet17), UIColor(resource: .colorSet18)]
}
