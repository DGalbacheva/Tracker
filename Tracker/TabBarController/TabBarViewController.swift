//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    let nameForTrackers = NSLocalizedString("trackers", comment: "Название вкладки трекеров")
    let nameForStatistics = NSLocalizedString("statistics", comment: "Название вкладки статистики")
    private var separator: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        trackersViewController.tabBarItem.image = UIImage(named: "TabBarTrackerIcon")
        trackersViewController.tabBarItem.title = nameForTrackers
        
        let statsViewController = StatsViewController()
        statsViewController.tabBarItem.image = UIImage(named: "TabBarStatsIcon")
        statsViewController.tabBarItem.title = nameForStatistics
        trackersViewController.delegate = statsViewController
        
        self.viewControllers = [navigationController, statsViewController]
    }
    
    private func addSeparatorLine() {
        if separator == nil {
            separator = CALayer()
            separator?.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1)
            tabBar.layer.addSublayer(separator!)
        }
        separator?.backgroundColor = UIColor.ypSeparatorForTabBar.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            addSeparatorLine()
        }
    }
}
