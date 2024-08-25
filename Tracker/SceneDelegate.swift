//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 08.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem.image = UIImage(named: "TabBarTrackerIcon")
        trackersViewController.tabBarItem.title = "Трекеры"
        
        let statsViewController = StatsViewController()
        statsViewController.tabBarItem.image = UIImage(named: "TabBarStatsIcon")
        statsViewController.tabBarItem.title = "Статистика"
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        let tabBarController = UITabBarController()
        
        tabBarController.viewControllers = [trackersNavigationController, statsViewController]
        
        window.rootViewController = tabBarController
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

