//
//  ViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 08.08.2024.
//

//MARK: - Home Screen

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func buttonTapped(in cell: TrackerCollectionViewCell)
}

final class TrackersViewController: UIViewController {
    //MARK: - Properties
    
    private let currentDate: Date = Date()
    private var selectedDate: Date = Date()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var datePicker = UIDatePicker()
    private lazy var mainLabel = UILabel()
    private lazy var searchTextField = UITextField()
    private lazy var placeholderImage = UIImageView()
    private lazy var placeholderLabel = UILabel()
    private lazy var plusButton = UIButton()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        filterTrackers(for: Date())
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        addSubViews()
    }
    
    //MARK: - UI Setup Methods
    
    private func addPlusButton() {
        let image = UIImage(named: "AddTrackerIcon")
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .blackDay
        plusButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    private func addDatePicker() {
        datePicker.datePickerMode  =  .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addMainLabel() {
        mainLabel.text = "Трекеры"
        mainLabel.font = .systemFont(ofSize: 34, weight: .bold)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            mainLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            mainLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func addSearchTextField() {
        searchTextField.backgroundColor = .backgroundDay
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.cornerRadius = 15
        searchTextField.font = .systemFont(ofSize: 17, weight: .regular)
        searchTextField.textAlignment = .left
        searchTextField.placeholder = "Поиск"
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        paddingView.addSubview(searchIcon)
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .unlessEditing
        searchTextField.leftViewMode = .always
        searchTextField.clearButtonMode = .whileEditing
        
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addPlaceholderImage() {
        placeholderImage.image = UIImage(named: "EmptyCollectionIcon")
        
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 70),
            placeholderImage.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func addPlaceholderLabel() {
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func addCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addSubViews() {
        addPlusButton()
        addDatePicker()
        addMainLabel()
        addSearchTextField()
        addPlaceholderImage()
        addPlaceholderLabel()
        addCollectionView()
    }
    
    //MARK: - Button Action
    
    //Set the click on the + button in the navbar
    @objc private func addButtonTapped() {
        let modalVC = TrackerTypeSelectionViewController()
        modalVC.delegate = self
        present(modalVC, animated: true)
        
    }
    
    //MARK: - Date Picker Actions
    
    //Filter the VisibleCategories array by weekday.numberValue when the date changes
    @objc func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        filterTrackers(for: sender.date)
    }
    
    //MARK: - Helper Methods
    
    private func showOrHideCollection() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
    }
    
    func filterTrackers(for date: Date) {
        guard let dayOfWeek = getDayOfWeek(from: date) else { return }
        visibleCategories = DataManager.shared.mockTrackers.map { category in
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(dayOfWeek) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        showOrHideCollection()
        collectionView.reloadData()
    }
    
    func getDayOfWeek(from date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        return WeekDay.allCases.first { $0.calendarDayNumber == weekday }
    }
    
    //Checking wether the tracker is completed today using the ID
    func isTrackerCompleted(_ tracker: Tracker, for date: Date) -> Bool {
        return completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

//MARK: - Extensions

//MARK: - UITextFieldDelegate

//Extension for correct operation of the search bar
extension TrackersViewController: UITextFieldDelegate {
    
    //A method that works on the Done button and returns the result
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //hides textfield
        
        return true //Returning the action (you can cancel it, but this is not necessary now)
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    //Returning the number of sections to the collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    //Return the number of elements in the section to the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    //Creating a cell to display on the screen
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell
        else {
            print("Didn't pass the cast")
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isComplete = isTrackerCompleted(tracker, for: selectedDate)
        let completionCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.configure(id: tracker.id, title: tracker.title, color: tracker.color, emoji: tracker.emoji, completedDays: completionCount, isEnabled: true, isCompletedToday: isComplete, indexPath: indexPath)
        cell.delegate = self
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
            assertionFailure("Invalid element type for SupplementaryElement")
            return UICollectionReusableView()
        }
        view.titleLabel.text = DataManager.shared.mockTrackers[indexPath.section].title
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 167, height: 148)
        
    }
    
    //Setting the size of each element (cell) in the collection
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    //Setting indents for the entire section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    //Header height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

//MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func buttonTapped(in cell: TrackerCollectionViewCell) {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let datePickerDate = Calendar.current.startOfDay(for: datePicker.date)
        
        //Storing the date selected in the calendar on this screen
        //And comparing these two dates here, if the selected date is greater
        //Than the current one, then don't call the code below
        if currentDate < datePickerDate {
            let alertController = UIAlertController(title: "Ой! Мы в будущем",
                                                    message: "Невозможно отметить этой датой",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ОК",
                                                    style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            if isTrackerCompleted(tracker, for: selectedDate) {
                completedTrackers.removeAll { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            } else {
                completedTrackers.append(record)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

//MARK: - TrackerTypeSelectionViewControllerDelegate

extension TrackersViewController: TrackerTypeSelectionViewControllerDelegate {
    func addNewTracker(category: String, tracker: Tracker) {
        if let categoryIndex = DataManager.shared.mockTrackers.firstIndex(where: { $0.title == category }) {
            var updatedCategory = DataManager.shared.mockTrackers[categoryIndex]
            updatedCategory = TrackerCategory(title: updatedCategory.title, trackers: updatedCategory.trackers + [tracker])
            DataManager.shared.mockTrackers[categoryIndex] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            DataManager.shared.mockTrackers.append(newCategory)
        }
        filterTrackers(for: selectedDate)
    }
}
