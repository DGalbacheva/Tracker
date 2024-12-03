//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 08.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let flagsAndSettings = FlagsAndSettings()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        
        if flagsAndSettings.hasSeenOnboarding {
            window.rootViewController = TabBarViewController()
        } else {
            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboardingVC.showMainView = { [weak self] in
                self?.showMainApp()
            }
            window.rootViewController = onboardingVC
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func showMainApp() {
        let mainTabBarController = TabBarViewController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
    }
}

