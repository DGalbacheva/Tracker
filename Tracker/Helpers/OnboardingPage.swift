//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import UIKit

enum OnboardingPage {
    case firstPage
    case secondPage
    
    var text: String {
        switch self {
        case .firstPage:
            return "Отслеживайте только то, что хотите"
        case .secondPage:
            return "Даже если это не литры воды и йога"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .firstPage:
            return UIImage(named: "OnboardingBlue")
        case .secondPage:
            return UIImage(named: "OnboardingRed")
        }
    }
}
