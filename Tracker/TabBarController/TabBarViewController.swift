//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        trackersViewController.tabBarItem.image = UIImage(named: "TabBarTrackerIcon")
        trackersViewController.tabBarItem.title = "Трекеры"
        
        let statsViewController = StatsViewController()
        statsViewController.tabBarItem.image = UIImage(named: "TabBarStatsIcon")
        statsViewController.tabBarItem.title = "Статистика"
        
        self.viewControllers = [navigationController, statsViewController]
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        let separator = CALayer()
        separator.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1)
        separator.backgroundColor = UIColor.ypLightGray.cgColor
        tabBar.layer.addSublayer(separator)
    }
}
