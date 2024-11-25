//
//  ViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 08.08.2024.
//

//MARK: - Home Screen

import UIKit
import YandexMobileMetrica

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func buttonTapped(in cell: TrackerCollectionViewCell)
}

final class TrackersViewController: UIViewController {
    //MARK: - Properties
    
    private let coreDataManager = CoreDataManager.shared
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()
    
    private let currentDate: Date = Date()
    private var selectedDate: Date = Date()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filteredTrackers: [TrackerCategory] = []
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var datePicker = UIDatePicker()
    private lazy var mainLabel = UILabel()
    private lazy var searchTextField = UISearchTextField()
    private lazy var placeholderImage = UIImageView()
    private lazy var placeholderLabel = UILabel()
    private lazy var plusButton = UIButton()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        coreDataManager.delegate = self
        coreDataManager.configureFetchedResultsController(for: WeekDay.fromDate(selectedDate))
        showOrHideCollection()
        filteredTrackers = visibleCategories
        
        addSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
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
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = .compact
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addMainLabel() {
        let text = NSLocalizedString("trackers", comment: "Текст для trackerLable")
        mainLabel.text = text
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
        let textForPlaceholder = NSLocalizedString("search", comment: "Текст для UITextField")
        searchTextField.placeholder = textForPlaceholder
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        paddingView.addSubview(searchIcon)
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .unlessEditing
        searchTextField.leftViewMode = .always
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
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
        let textForLable = NSLocalizedString("emptyState.title", comment: "Текст для заглушки")
        placeholderLabel.text = textForLable
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
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_tracker"])
        let modalVC = TrackerTypeSelectionViewController()
        present(modalVC, animated: true)
        
    }
    
    @objc func textDidChange() {
        if let searchText = searchField.text, !searchText.isEmpty {
            filteredTrackers = visibleTrackers.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.name.localizedCaseInsensitiveContains(searchText)
                }
                
                if !filteredTrackers.isEmpty {
                    return TrackerCategory(title: category.title, trackers: filteredTrackers)
                } else {
                    return nil
                }
            }
        } else {
            filteredTrackers = visibleTrackers
        }
        collectionView.reloadData()
        showOrHideCollection()
    }
    
    //MARK: - Date Picker Actions
    
    //Filter the VisibleCategories array by weekday.numberValue when the date changes
    @objc func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        coreDataManager.configureFetchedResultsController(for: WeekDay.fromDate(selectedDate))
    }
    
    //MARK: - Helper Methods
    
    private func showOrHideCollection() {
        if filteredTrackers.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
    }
    
    func getDayOfWeek(from date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        return WeekDay.allCases.first { $0.calendarDayNumber == weekday }
    }
    
    //Checking wether the tracker is completed today using the ID
    func isTrackerCompleted(_ tracker: Tracker, for date: Date) -> Bool {
        return trackerRecordStore.isTrackerCompleted(trackerId: tracker.id, date: date)
    }
}

//MARK: - Extensions

//MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    //Returning the number of sections to the collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredTrackers.count
    }
    
    //Return the number of elements in the section to the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredTrackers[section].trackers.count
    }
    
    //Creating a cell to display on the screen
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell
        else {
            print("Didn't pass the cast")
            return UICollectionViewCell()
        }
        
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        
        let completionCount = trackerRecordStore.getTrackerRecords(by: tracker.id).count
        let isCompleteToday = isTrackerCompleted(tracker, for: selectedDate)
        cell.configure(id: tracker.id, title: tracker.title, color: tracker.color, emoji: tracker.emoji, completedDays: completionCount, isEnabled: true, isCompletedToday: isCompleteToday, indexPath: indexPath)
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
        view.titleLabel.text = filteredTrackers[indexPath.section].title
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

//MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        let deleteCellString = NSLocalizedString("delete", comment: "text for contextMenu")
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                
                UIAction(title: deleteCellString) { [weak self] _ in
                    self?.confirmingDeletionAlert(indexForDelete: indexPath)
                }
            ])
        })
    }
    
    private func deleteCell(indexPath: IndexPath) {
        //            let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        
    }
    
    private func confirmingDeletionAlert(indexForDelete: IndexPath) {
        let deleteCellString = NSLocalizedString("delete", comment: "text for delete button")
        let abortString = NSLocalizedString("cancel", comment: "text for cancel button")
        let titleForAlert = NSLocalizedString("delete.confirmation", comment: "Title for alert")
        let alert = UIAlertController(title: titleForAlert, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteCellString, style: .destructive) { [weak self] _ in
            self?.deleteCell(indexPath: indexForDelete)
        }
        let cancelAction = UIAlertAction(title: abortString, style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        
        do {
            if isTrackerCompleted(tracker, for: selectedDate) {
                trackerRecordStore.removeTrackerRecord(trackerId: tracker.id, date: selectedDate)
            } else {
                try trackerRecordStore.addTrackerRecord(trackerId: tracker.id, date: selectedDate)
            }
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Error updating tracker state: \(error)")
        }
    }
}

//MARK: - CoreDataManagerDelegate

extension TrackersViewController: CoreDataManagerDelegate {
    func didChangeData(_ data: [TrackerCategory]) {
        visibleCategories = data
        filteredTrackers = data
        textDidChange()
        showOrHideCollection()
        collectionView.reloadData()
    }
}


