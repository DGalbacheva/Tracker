//
//  DataManager.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 23.08.2024.
//

import Foundation

final class DataManager {
    // Создаем синглтон
    static let shared = DataManager()
    
    // Приватный инициализатор, чтобы предотвратить создание более одного экземпляра
    private init() {}
    
    // Массив с моковыми данными
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers:
                            [Tracker(id: UUID(), date: Date(), emoji: "❤️", title: "Поливать растения", color: .colorSet5, dayCount: 1, schedule: [.monday])]),
        
        TrackerCategory(title: "Радостные мелочи", trackers:
                            [Tracker(id: UUID(), date: Date(), emoji: "😻", title: "Кошка заслонила камеру на созвоне", color: .colorSet2, dayCount: 5, schedule: [.monday, .sunday, .thursday]),
                             Tracker(id: UUID(), date: Date(), emoji: "🌺", title: "Бабушка прислала открытку в вотсаппе", color: .colorSet1, dayCount: 4, schedule: [.wednesday, .thursday, .saturday]),
                             Tracker(id: UUID(), date: Date(), emoji: "❤️", title: "Свидания в апреле", color: .colorSet14, dayCount: 5, schedule: [.monday, .friday])
                            ])
    ]
}
