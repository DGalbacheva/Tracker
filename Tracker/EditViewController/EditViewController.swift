//
//  EditViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 26.11.2024.
//

import UIKit

final class EditViewController: UIViewController {
    
    //MARK: - Properties
    
    enum TrackerType {
        case habit
        case event
    }
    
    private let marshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    var trackerType: TrackerType = .habit
    
    var coudDays: Int = 0
    var id: UUID? = nil
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?
    var colorForTracer: UIColor?
    var emojiForTracker: String?
    var weekDaysArrayForTracker: [WeekDay] = []
    var textFieldIsEmpty: Bool = false
    var nameForTracker: String = ""
    var categoryForTracker: String = ""
    var weekdaysForTracker: String {
        var string: String = ""
        for i in weekDaysArrayForTracker {
            string += " \(i.shortDayName),"
        }
        return string
    }
    
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors: [UIColor] = [UIColor(resource: .colorSet1), UIColor(resource: .colorSet2), UIColor(resource: .colorSet3), UIColor(resource: .colorSet4), UIColor(resource: .colorSet5), UIColor(resource: .colorSet6), UIColor(resource: .colorSet7), UIColor(resource: .colorSet8), UIColor(resource: .colorSet9), UIColor(resource: .colorSet10), UIColor(resource: .colorSet11), UIColor(resource: .colorSet12), UIColor(resource: .colorSet13), UIColor(resource: .colorSet14), UIColor(resource: .colorSet15), UIColor(resource: .colorSet16), UIColor(resource: .colorSet17), UIColor(resource: .colorSet18)]
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var countDaysLable = UILabel()
    private lazy var nameTrackerTextField = UITextField()
    private lazy var trackerTableView = UITableView(frame: .zero)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var createButton = UIButton()
    private lazy var cancelButton = UIButton(type: .system)
    
    private var rowsForTableView: [String] {
        return trackerType == .habit ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        trackerTableView.dataSource = self
        trackerTableView.delegate = self
        configureSubviews()
    }
    
    //MARK: - UI Setup Methods
    
    func configureSubviews() {
        scrollView.alwaysBounceVertical = true
        titleLabel.text = trackerType == .habit ? "Редактирование привычки" : "Редактирование события"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .blackDay
        
        countDaysLable.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи дня"),
            coudDays
        )
        countDaysLable.font = .systemFont(ofSize: 32, weight: .bold)
        countDaysLable.textAlignment = .center
        
        nameTrackerTextField.backgroundColor = .backgroundDay
        nameTrackerTextField.layer.masksToBounds = true
        nameTrackerTextField.layer.cornerRadius = 15
        nameTrackerTextField.font = .systemFont(ofSize: 16, weight: .regular)
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.textAlignment = .left
        nameTrackerTextField.textColor = .blackDay
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        nameTrackerTextField.leftView = leftView
        nameTrackerTextField.leftViewMode = .always
        nameTrackerTextField.clearButtonMode = .whileEditing
        nameTrackerTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        nameTrackerTextField.delegate = self
        nameTrackerTextField.text = nameForTracker
        
        trackerTableView.register(HabitOrEventTableViewСеll.self, forCellReuseIdentifier: HabitOrEventTableViewСеll.identifier)
        trackerTableView.separatorStyle = .singleLine
        trackerTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerTableView.layer.masksToBounds = true
        trackerTableView.layer.cornerRadius = 16
        trackerTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HabitOrEventCollectionViewCell.self, forCellWithReuseIdentifier: HabitOrEventCollectionViewCell.identifier)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        
        createButton.setTitle("Сохранить", for: .normal)
        createButton.tintColor = .whiteDay
        createButton.backgroundColor = .ypGray
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonIsClicked), for: .touchUpInside)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.backgroundColor = .whiteDay
        cancelButton.tintColor = .ypRed
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonIsClicked), for: .touchUpInside)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countDaysLable.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        trackerTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(countDaysLable)
        contentView.addSubview(nameTrackerTextField)
        contentView.addSubview(trackerTableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(createButton)
        contentView.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            countDaysLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            countDaysLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countDaysLable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            countDaysLable.heightAnchor.constraint(equalToConstant: 40),
            
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: countDaysLable.bottomAnchor, constant: 24),
            
            trackerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            trackerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerTableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: trackerTableView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 700),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 160),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 160),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    //MARK: - Actions
    
    @objc private func editingChanged() {
        if let text = nameTrackerTextField.text, !text.isEmpty {
            textFieldIsEmpty = false
        }
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonIsClicked() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonIsClicked() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        guard let color = colorForTracer, let emoji = emojiForTracker else {return}
        var tracker: Tracker
        if let text = nameTrackerTextField.text {
            if trackerType == .habit {
                tracker = Tracker(id: UUID(), title: text, color: color, emoji: emoji, schedule: weekDaysArrayForTracker)
            } else {
                weekDaysArrayForTracker = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                tracker = Tracker(id: UUID(), title: text, color: color, emoji: emoji, schedule: weekDaysArrayForTracker)
            }
            trackerStore.addNewTracker(tracker: tracker, categoryName: categoryForTracker)
            trackerStore.deleteTracker(id: id!)
        }
    }
    
    //MARK: - Methods
    
    func pickedEmojiAndColor(emoji: String, color: UIColor) {
        guard let emojiIndex = emojies.firstIndex(of: emoji) else {
            print("Could not find emoji in array")
            return
        }
        
        let convertedColor = marshalling.hexString(from: color)
        let convertedArray = colors.map { color in
            marshalling.hexString(from: color)
        }

        guard  let colorIndex = convertedArray.firstIndex(of: convertedColor) else {
            print("Could not find color in array")
            return
        }
        
        selectedEmojiIndexPath = IndexPath(row: emojiIndex, section: 0)
        selectedColorIndexPath = IndexPath(row: colorIndex, section: 1)
        colorForTracer = colors[colorIndex]
        emojiForTracker = emojies[emojiIndex]
    }
    
    internal func updateCreateButtonState() {
        if textFieldIsEmpty == false, (trackerType == .event || !weekDaysArrayForTracker.isEmpty), !categoryForTracker.isEmpty, colorForTracer != nil, emojiForTracker != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDay
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
}
//MARK: - UITextFieldDelegate

extension EditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

//MARK: - UITableViewDelegate

extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel()
            viewModel.delegate = self
            viewModel.pickCategory = categoryForTracker
            let viewController = CategoryViewController(categoryViewModel: viewModel)
            present(viewController, animated: true)
        } else if trackerType == .habit && indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            viewController.weekDaysArrayFromVC = weekDaysArrayForTracker
            present(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventTableViewСеll.identifier, for: indexPath) as? HabitOrEventTableViewСеll else {
            assertionFailure("Failed to cast to EventOrHabitTableViewСеll")
            return UITableViewCell()
        }
        
        let text = rowsForTableView[indexPath.row]
        cell.configureNameLable(textNameLable: text)
        if indexPath.row == 0 {
            cell.descriptionLabelIsEmpty = categoryForTracker.isEmpty
            cell.configureDescriptionLabel(textDescriptionLabel: categoryForTracker)
        } else if trackerType == .habit && indexPath.row == 1 {
            if weekDaysArrayForTracker.count == 7 {
                cell.configureDescriptionLabel(textDescriptionLabel: "Каждый день")
            } else {
                cell.descriptionLabelIsEmpty = weekdaysForTracker.isEmpty
                cell.configureDescriptionLabel(textDescriptionLabel: weekdaysForTracker)
            }
        }
        cell.backgroundColor = .backgroundDay
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UICollectionViewDataSource

extension EditViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojies.count
        } else if section == 1 {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitOrEventCollectionViewCell.identifier, for: indexPath) as? HabitOrEventCollectionViewCell
        else {
            print("Didn't pass the cast HabitOrEventCollectionViewCell")
            return UICollectionViewCell()
        }
        
        cell.reset()
        if indexPath.section == 0 {
            cell.configEmojiCell(emoji: emojies[indexPath.row])
            
            if indexPath == selectedEmojiIndexPath {
                cell.selectEmoji()
            } else {
                cell.deselectEmoji()
            }
            
        } else if indexPath.section == 1 {
            cell.configColorCell(color: colors[indexPath.row])
            if indexPath == selectedColorIndexPath {
                let colorForBorder = colors[indexPath.row].withAlphaComponent(0.3)
                cell.selectColor(color: colorForBorder)
            } else {
                cell.deselectColor()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SectionHeader else {
            assertionFailure("Failed to cast to SectionHeader")
            return UICollectionReusableView()
        }
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        } else {
            view.titleLabel.text = "Цвет"
        }
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension EditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

//MARK: - UICollectionViewDelegate

extension EditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if let selectedEmojiIndexPath = selectedEmojiIndexPath, let previousCell = collectionView.cellForItem(at: selectedEmojiIndexPath) as? HabitOrEventCollectionViewCell {
                previousCell.deselectEmoji()
            }
            selectedEmojiIndexPath = indexPath
            emojiForTracker = emojies[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? HabitOrEventCollectionViewCell {
                cell.selectEmoji()
            }
        }
        else if indexPath.section == 1 {
            if let selectedColorIndexPath = selectedColorIndexPath, let previousCell = collectionView.cellForItem(at: selectedColorIndexPath) as? HabitOrEventCollectionViewCell {
                previousCell.deselectColor()
            }
            selectedColorIndexPath = indexPath
            colorForTracer = colors[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? HabitOrEventCollectionViewCell {
                let colorForBorder = colors[indexPath.row].withAlphaComponent(0.3)
                cell.selectColor(color: colorForBorder)
            }
        }
        updateCreateButtonState()
    }
}

//MARK: - CategoryViewModelDelegate

extension EditViewController: CategoryViewModelDelegate {
    func categoryIsPicked(category: String) {
        categoryForTracker = category
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}

//MARK: - ScheduleViewControllerDelegate

extension EditViewController: ScheduleViewControllerDelegate {
    func weekdaysIsPicked(weekDaysArray: [WeekDay]) {
        weekDaysArrayForTracker = weekDaysArray
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}
