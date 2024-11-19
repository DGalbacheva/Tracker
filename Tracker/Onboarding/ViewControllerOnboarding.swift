//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    private lazy var button = UIButton()
    private lazy var imageView = UIImageView()
    private lazy var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
    }
    
    private func configureSubviews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .whiteDay
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(targetForButton), for: .touchUpInside)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .blackDay
        label.numberOfLines = 2
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 15),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc
    private func targetForButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        if let window = UIApplication.shared.windows.first {
            let newViewController = TabBarViewController()
            window.rootViewController = newViewController
            window.makeKeyAndVisible()
        }
    }
    func configLableAndImage(text: String, image: UIImage?) {
        label.text = text
        imageView.image = image
    }

}
