//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 25.11.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "ae7de4b6-a8e8-4283-92bd-1435dd1b2bdb") else { return }

        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
