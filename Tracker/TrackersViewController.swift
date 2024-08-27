//
//  ViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 08.08.2024.
//

//MARK: - Home Screen

import UIKit

final class TrackersViewController: UIViewController {
    
    //Storing the date selected in the picker
    var currentDate: Date = Date()
    
    //Declare a singleton with mock data
    private let dataManager = DataManager.shared
    
    //An array with all created trackers
    private var categories: [TrackerCategory] = []
    
    //Array with trackers visible on the screen
    private var visibleCategories: [TrackerCategory] = []
    
    //Storage of completed tracker records
    private var completedTrackers: [TrackerRecord] = []
    
    //Section headings (headers)
    private var sectionTitles = ["Домашний уют", "Радостные мелочи", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    
    
    //MARK: - UI Elements
    
    //Collection instance
    private var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        
        //Cell type
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        //Header type
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        
        return collectionView
    }()
    
    //Collection DatePicker
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.widthAnchor.constraint(equalToConstant: 100).isActive = true
       // picker.calendar.firstWeekday = 2
        return picker
    }()
    
    //Collection UILabel
    private var mainLabel: UILabel = {
        let mainLabel = UILabel()
        mainLabel.text = "Трекеры"
        mainLabel.textColor = .blackDay
        mainLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return mainLabel
    }()
    
    //Collection UISearchTextField
    private var searchTextField: UISearchTextField = {
        let field = UISearchTextField()
        field.backgroundColor = .backgroundDay
        field.placeholder = "Поиск"
        field.returnKeyType = .done
        // field.delegate = .done
        return field
    }()
    
    //Placeholder image for an empty collection
    private var placeholderImage: UIImageView = {
        let image = UIImage(named: "EmptyCollectionIcon")
        let emptyCollectionIcon = UIImageView(image: image)
        return emptyCollectionIcon
    }()
    
    //Placeholder text
    private var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the background for the screen
        view.backgroundColor = .whiteDay
        
        //Updating data depending on the availability of trackers and date
        reloadData()
        
        //Monitoring changes in picker value
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        //Monitoring the changes in the search string and issue trackers in real time
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        //Create a Notifier to signal that tracker creation is canceled and all modal screens are closed
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeAllModalViewControllers),
                                               name: Notification.Name("CloseAllModals"), object: nil)
        
        //Creating a Notifier for the signal about the creation of a new tracker in NewHabitViewController
        NotificationCenter.default.addObserver(self, selector: #selector(newTrackerCreated), name: NSNotification.Name("NewTrackerCreated"), object: nil)
        
        //Displaying the collection and other UI elements
        addSubviews()
        
        //NavigationBar buttons
        if let naviBar = navigationController?.navigationBar {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            addButton.tintColor = .blackDay
            naviBar.topItem?.setLeftBarButton(addButton, animated: false)
            
            let datePickerButton = UIBarButtonItem(customView: datePicker)
            naviBar.topItem?.setRightBarButton(datePickerButton, animated: false)
        }
    }
    
    //Set the click on the + button in the navbar
    @objc private func addButtonTapped() {
        let modalVC = AddTrackerViewController()
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    //Set all modal screens to close if the tracker creation is canceled
    @objc private func closeAllModalViewControllers() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Checking wether the tracker is completed today using the ID
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    //Method for comparing tracker entries
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date,
                                                inSameDayAs: datePicker.date)
        return trackerRecord.trackerId == id && isSameDay
    }
    
    private func reloadData() {
        categories = dataManager.categories
        dateChanged()
    }
    
    @objc private func newTrackerCreated() {
        reloadData()
    }
    
    //Filter the VisibleCategories array by weekday.numberValue when the date changes
    @objc private func dateChanged() {
        currentDate = datePicker.date
        reloadVisibleCategories()
    }
    
    @objc private func searchTextChanged() {
        reloadVisibleCategories()
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekDay = calendar.component(.weekday, from: currentDate)
        let filterText = (searchTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                
                //Condition for text in search
                let textCondition = filterText.isEmpty || //If the field is empty, then display it anyway
                tracker.title.lowercased().contains(filterText)
                var dateCondition: Bool {
                    guard !(tracker.schedule ?? []).isEmpty else {
                        let calendar = Calendar.current
                        let currentSelectedDay = calendar.dateComponents([.year, .month, .day], from: currentDate)
                        let trackerCreationDate = calendar.dateComponents([.year, .month, .day], from: tracker.date)
                        return currentSelectedDay == trackerCreationDate
                    }
                    return tracker.schedule?.contains { weekDay in
                        weekDay.rawValue == filterWeekDay
                    } == true
                }
                
                //Checking the two conditions and return them
                return textCondition && dateCondition
            }
            
            //If the category is empty, skip it
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        //Reload the collection according to the result
        trackerCollectionView.reloadData()
        reloadPlaceholder()
    }
    
    //Display a placeholder if there are no trackers yet
    private func reloadPlaceholder() {
        if categories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else if visibleCategories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
            placeholderLabel.text = "Что будем отслеживать?"
        } else {
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
    
    
    //MARK: - UI Elements Layout
    
    private func addSubviews() {
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        view.addSubview(searchTextField)
        view.addSubview(trackerCollectionView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        
        trackerCollectionView.dataSource = self
        trackerCollectionView.delegate = self
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            
            trackerCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - Extensions

//Extension for correct operation of the search bar
extension TrackersViewController: UITextFieldDelegate {
    
    //A method that works on the Done button and returns the result
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //hides textfield
        
        reloadVisibleCategories()
        
        return true //Returning the action (you can cancel it, but this is not necessary now)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
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
        } else {
            let trackerRecord = TrackerRecord(trackerId: id, date: datePicker.date)
            completedTrackers.append(trackerRecord)
            trackerCollectionView.reloadItems(at: [indexPath])
        }
    }
        
        func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
            completedTrackers.removeAll { trackerRecord in
                isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
            }
            trackerCollectionView.reloadItems(at: [indexPath])
        }
    }


extension TrackersViewController: UICollectionViewDataSource {
    //Returning the number of sections to the collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    //Return the number of elements in the section to the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = visibleCategories[section].trackers
        return trackers.count
    }
    
    //Creating a cell to display on the screen
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackerCollectionViewCell
        
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.item]
        
        cell.delegate = self
        
        //Passing the value of whether the tracker is completed today
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        //Counting how many records are stored in completed trackers with a specific ID
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath)
        
        return cell
    }
}

//extension TrackersViewController: UICollectionViewDelegate {
//
//}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 2) - 20.0, height: 148)
        
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
        UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
    
    //Header height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as! SectionHeader
            //Title for the section
            headerView.titleLabel.text = sectionTitles[indexPath.section]
            return headerView
            
        default:
            assert(false, "Invalid element type for SupplementaryElement")
        }
    }
}
