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
    var mockTrackers: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers:
                            [Tracker(id: UUID(),  title: "Поливать растения", color: .colorSet5, emoji: "❤️", schedule: [.monday])]),
        
        TrackerCategory(title: "Радостные мелочи", trackers:
                            [Tracker(id: UUID(),  title: "Кошка заслонила камеру на созвоне", color: .colorSet2, emoji: "😻", schedule: [.monday, .sunday, .thursday]),
                             Tracker(id: UUID(),  title: "Бабушка прислала открытку в вотсаппе", color: .colorSet1, emoji: "🌺", schedule: [.wednesday, .thursday, .saturday]),
                             Tracker(id: UUID(),  title: "Свидания в апреле", color: .colorSet14, emoji: "❤️", schedule: [.monday, .friday])
                            ])
    ]
}
