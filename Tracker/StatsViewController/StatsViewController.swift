//
//  StatsViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 15.08.2024.
//

//MARK: - Statisctics Screen

import UIKit

final class StatsViewController: UIViewController, TrackerViewControllerDelegateForStatistic {
    private let trackerRecordStore = TrackerRecordStore()
    
    private var countDays: Int = 0
    
    private lazy var titleLabel = UILabel()
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLabel = UILabel()
    private lazy var holderForStatistic = UIView()
    private lazy var countLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        
        whatsShow(days: trackerRecordStore.getAllTrackerRecords().count)
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientBorder()
    }
    
    private func applyGradientBorder() {
        if let sublayers = holderForStatistic.layer.sublayers, sublayers.count > 0 {
            for layer in sublayers where layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = holderForStatistic.bounds
        gradientLayer.cornerRadius = holderForStatistic.layer.cornerRadius
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: holderForStatistic.bounds, cornerRadius: holderForStatistic.layer.cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        holderForStatistic.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureView() {
        titleLabel.text = "Статистика"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        holderForStatistic.layer.masksToBounds = true
        holderForStatistic.layer.cornerRadius = 16
        holderForStatistic.layer.borderWidth = 1
        holderForStatistic.layer.borderColor = UIColor.clear.cgColor
        
        countLabel.text = "\(countDays)"
        countLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        descriptionLabel.text = "Трекеров завершено"
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        placeholder.image = UIImage(named: "statisticNil")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.text = "Анализировать пока нечего"
        placeholderLabel.textAlignment = .center
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        holderForStatistic.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(holderForStatistic)
        view.addSubview(titleLabel)
        view.addSubview(placeholder)
        view.addSubview(placeholderLabel)
        holderForStatistic.addSubview(countLabel)
        holderForStatistic.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholder.bottomAnchor,constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            holderForStatistic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            holderForStatistic.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            holderForStatistic.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 75),
            holderForStatistic.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.leadingAnchor.constraint(equalTo: holderForStatistic.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: holderForStatistic.topAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: holderForStatistic.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: holderForStatistic.bottomAnchor, constant: -12)
        ])
    }
    
    func whatsShow(days: Int) {
        countDays = days
        countLabel.text = "\(countDays)"
        
        if countDays == 0 {
            holderForStatistic.isHidden = true
            placeholder.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            holderForStatistic.isHidden = false
            placeholder.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
}
