//
//  TrackerCollectionView.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 16.08.2024.
//

//MARK: - Tracker Cell Class

import UIKit
import YandexMobileMetrica

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCollectionViewCell"
    private let coreDataManager = CoreDataManager.shared
    private let trackerStore = TrackerStore()
    private let analyticsService = AnalyticsService()
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    private var indexPath: IndexPath?
    private var countDays: Int = 0
    
    private var categoryName: String = ""
    private var weekDays: [WeekDay] = []
    private var color: UIColor? = nil
    
    //MARK: - UI Elements
    
    //Top part
    private var upperView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSet14
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Bottom part
    private var lowerView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteDay
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Emoji
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Emoji UIView
    private var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteDay.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //LableText Tracker
    private var trackerText: UITextView = {
        let text = UITextView()
        text.textColor = .whiteDay
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.backgroundColor = .clear
        text.isScrollEnabled = false
        text.textContainerInset = UIEdgeInsets.zero
        text.textContainer.lineFragmentPadding = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    //Days counter
    private var dayCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Plus or Minus Button
    private var plusButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "PlusButton")?.withRenderingMode(.alwaysTemplate)
        button.setImage(templateImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Image for the plus button under the tracker
    private var plusImage: UIImage = {
        let image = UIImage(named: "PlusButton")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        return image
    }()
    
    // Картинка для кнопки done под трекером
    private var doneImage: UIImage = {
        let image = UIImage(named: "DoneButton") ?? UIImage()
        return image
    }()
    
    //MARK: - UI Elements Layout
    
    //Initializer for cell settings
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContextMenuInteraction()
        addSubViewAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubViewAndConstraints() {
        // Cell color
        upperView.backgroundColor = .colorSet14
        // Round ends of cells
        upperView.layer.cornerRadius = 16
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(upperView)
        contentView.addSubview(lowerView)
        upperView.addSubview(emojiBackgroundView)
        upperView.addSubview(emojiLabel)
        upperView.addSubview(trackerText)
        lowerView.addSubview(dayCountLabel)
        lowerView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: contentView.topAnchor),
            upperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upperView.heightAnchor.constraint(equalToConstant: 90),
            
            lowerView.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            lowerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lowerView.heightAnchor.constraint(equalToConstant: 58),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            trackerText.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 44),
            trackerText.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 12),
            trackerText.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -12),
            trackerText.bottomAnchor.constraint(equalTo: upperView.bottomAnchor, constant: -12),
            trackerText.widthAnchor.constraint(equalToConstant: 143),
            trackerText.heightAnchor.constraint(equalToConstant: 34),
            
            dayCountLabel.centerYAnchor.constraint(equalTo: lowerView.centerYAnchor),
            dayCountLabel.leadingAnchor.constraint(equalTo: lowerView.leadingAnchor, constant: 10),
            
            plusButton.centerYAnchor.constraint(equalTo: lowerView.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: lowerView.trailingAnchor, constant: -10),
        ])
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        upperView.addInteraction(interaction)
    }
    
    // Метод для "собирания" ячейки
    func configure(
        id:  UUID,
        title:  String,
        color: UIColor,
        emoji: String,
        completedDays: Int,
        isEnabled: Bool,
        isCompletedToday: Bool,
        indexPath: IndexPath,
        categoryName: String,
        weekDays: [WeekDay]
    ) {
        self.trackerId = id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        self.categoryName = categoryName
        self.weekDays = weekDays
        self.color = color
        self.countDays = completedDays
        
        upperView.backgroundColor = color
        plusButton.tintColor = color
        trackerText.text = title
        emojiLabel.text = emoji
        
        dayCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи дня"),
            completedDays
        )
        
        let image = isCompletedToday ? doneImage : plusImage
        plusButton.setImage(image, for: .normal)
    }
    
    func pinOrUnPinTracker(category: String) -> UIAction {
        if category == "Закрепленные" {
            return UIAction(title: "Открепить") { [weak self] _ in
                guard let self = self else {return}
                self.trackerStore.unpinTracker(id: self.trackerId!)
            }
        } else {
            return UIAction(title: "Закрепить") { [weak self] _ in
                guard let self = self else {return}
                self.trackerStore.pinTracker(id: self.trackerId!)
            }
        }
    }
    
    @objc private func plusButtonTapped() {
        delegate?.buttonTapped(in: self)
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "plus_on_trackerCard"])
    }
}
// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let deleteCellString = NSLocalizedString("delete", comment: "text for contextMenu")
        let deleteCellAttributedString = NSAttributedString(
            string: deleteCellString,
            attributes: [.foregroundColor: UIColor.red]
        )
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return UIMenu(children: [
                self.pinOrUnPinTracker(category: self.categoryName),
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let self = self else {return}
                    self.analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
                    self.editFlow(self: self)
                }),
                UIAction(title: deleteCellString, attributes: .destructive) { [weak self] _ in
                    guard let self = self else {return}
                    if let indexPath = self.indexPath {
                        self.analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
                        self.confirmingDeletionAlert(indexForDelete: indexPath)
                    }
                }
            ])
        }
    }
    
    private func confirmingDeletionAlert(indexForDelete indexPath: IndexPath) {
        let deleteCellString = NSLocalizedString("delete", comment: "text for delete button")
        let abortString = NSLocalizedString("cancel", comment: "text for cancel button")
        let titleForAlert = NSLocalizedString("delete.confirmation", comment: "Title for alert")
        let alert = UIAlertController(title: titleForAlert, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteCellString, style: .destructive) { [weak self] _ in
            self?.deleteCell()
        }
        let cancelAction = UIAlertAction(title: abortString, style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.delegate?.confirmingDeletionAlert(alert: alert)
    }
    
    private func deleteCell() {
        guard let id = trackerId else {return}
        trackerStore.deleteTracker(id: id)
        print("Deleting the tracker")
    }
    
    private func editFlow(self: TrackerCollectionViewCell) {
        let vs = EditViewController()
        vs.trackerType = .habit
        vs.categoryForTracker = self.categoryName
        vs.weekDaysArrayForTracker = self.weekDays
        vs.nameForTracker = self.trackerText.text!
        vs.pickedEmojiAndColor(emoji: self.emojiLabel.text!, color: self.color!)
        vs.id = self.trackerId
        vs.coudDays = countDays
        vs.configureSubviews()
        self.delegate?.showEditView(controller: vs)
    }
}
