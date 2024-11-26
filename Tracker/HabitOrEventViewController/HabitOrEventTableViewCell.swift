//
//  HabitOrEventTableViewCell.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 10.09.2024.
//

import UIKit

final class HabitOrEventTableViewСеll: UITableViewCell {
    
    static let identifier = "HabitOrEventTableViewСеll"
    
    private lazy var chevronImg: UIImageView = {
        return UIImageView(image: UIImage(named: "chevron"))
    }()
    private lazy var nameLable = UILabel()
    private lazy var descriptionLabel = UILabel()
    private var descriptionLabelTopConstraint: NSLayoutConstraint!
    private var nameLabelCenterYConstraint: NSLayoutConstraint!
    
    var descriptionLabelIsEmpty = false {
        didSet {
            updateConstraintsForDescriptionLabel()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        nameLable.font = .systemFont(ofSize: 17, weight: .regular)
        nameLable.textColor = .blackDay
        
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textColor = .ypGray
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        chevronImg.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(chevronImg)
        contentView.addSubview(nameLable)
        
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 75)
        heightCell.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            heightCell,
            chevronImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            chevronImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImg.heightAnchor.constraint(equalToConstant: 24),
            chevronImg.widthAnchor.constraint(equalToConstant: 24),
            
            nameLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLable.heightAnchor.constraint(equalToConstant: 24),
            nameLable.trailingAnchor.constraint(equalTo: chevronImg.leadingAnchor),
            nameLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLable.bottomAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLable.trailingAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        updateConstraintsForDescriptionLabel()
    }
    
    private func updateConstraintsForDescriptionLabel() {
        if descriptionLabelIsEmpty {
            descriptionLabel.isHidden = true
            descriptionLabelTopConstraint.isActive = false
            nameLabelCenterYConstraint.isActive = true
        } else {
            descriptionLabel.isHidden = false
            nameLabelCenterYConstraint.isActive = false
            descriptionLabelTopConstraint.isActive = true
        }
    }
    
    func configureNameLable(textNameLable: String) {
        nameLable.text = textNameLable
    }
    
    func configureDescriptionLabel(textDescriptionLabel: String) {
        var text = textDescriptionLabel
        if text.last == "," {
            text.removeLast()
        }
        descriptionLabel.text = text
    }
}
