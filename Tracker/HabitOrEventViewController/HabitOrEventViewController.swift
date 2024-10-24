//
//  HabitOrEventViewController.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 10.09.2024.
//

import UIKit

protocol HabitOrEventViewControllerDelegate: AnyObject {
    func didCreateTracker(category: String, tracker: Tracker)
}

final class HabitOrEventViewController: UIViewController {
    enum TrackerType {
        case habit
        case event
    }
    
    weak var delegate: HabitOrEventViewControllerDelegate?
    var trackerType: TrackerType = .habit
    var weekDaysArrayForTracker: [WeekDay] = []
    var textFieldIsEmpty: Bool = true
    var categoryForTracker: String = ""
    var weekdaysForTracker: String {
        var string: String = ""
        for i in weekDaysArrayForTracker {
            string += " \(i.shortDayName),"
        }
        return string
    }
    
    private lazy var titleLabel = UILabel()
    private lazy var nameTrackerTextField = UITextField()
    private lazy var trackerTableView = UITableView(frame: .zero)
    private lazy var createButton = UIButton()
    private lazy var cancelButton = UIButton(type: .system)
    private var rowsForTableView: [String] {
        return trackerType == .habit ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        trackerTableView.dataSource = self
        trackerTableView.delegate = self
        configureSubviews()
    }
    
    private func configureSubviews() {
        titleLabel.text = trackerType == .habit ? "Новая привычка" : "Новое событие"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .blackDay
        
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
        
        trackerTableView.register(HabitOrEventTableViewСеll.self, forCellReuseIdentifier: HabitOrEventTableViewСеll.identifier)
        trackerTableView.separatorStyle = .singleLine
        trackerTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerTableView.layer.masksToBounds = true
        trackerTableView.layer.cornerRadius = 16
        trackerTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        createButton.setTitle("Создать", for: .normal)
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
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        trackerTableView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(nameTrackerTextField)
        view.addSubview(trackerTableView)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            
            trackerTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            trackerTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerTableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 160),
            
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 160),
        ])
    }
    
    @objc private func editingChanged() {
        if let text = nameTrackerTextField.text, !text.isEmpty {
            textFieldIsEmpty = false
            updateCreateButtonState()
        }
    }
    
    @objc private func cancelButtonIsClicked() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonIsClicked() {
        dismiss(animated: true)
        var tracker: Tracker
        if let text = nameTrackerTextField.text {
            if trackerType == .habit {
                tracker = Tracker(id: UUID(), title: text, color: .colorSet4, emoji: "🍄", schedule: weekDaysArrayForTracker)
            } else {
                weekDaysArrayForTracker = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                tracker = Tracker(id: UUID(), title: text, color: .colorSet4, emoji: "🍄", schedule: weekDaysArrayForTracker)
            }
            delegate?.didCreateTracker(category: categoryForTracker, tracker: tracker)
        }
    }
    
    internal func updateCreateButtonState() {
        if textFieldIsEmpty == false, (trackerType == .event || !weekDaysArrayForTracker.isEmpty), !categoryForTracker.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDay
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
}

extension HabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewController = CategoryViewController()
            viewController.delegateForHabit = self
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

extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventTableViewСеll.identifier, for: indexPath) as? HabitOrEventTableViewСеll else {
            assertionFailure("Не удалось выполнить приведение к EventAndHabitTableViewСеll")
            return UITableViewCell()
        }
        let text = rowsForTableView[indexPath.row]
        cell.configureNameLable(textNameLable: text)
        if indexPath.row == 0 {
            cell.configureDescriptionLable(textDescriptionLable: categoryForTracker)
        } else if trackerType == .habit && indexPath.row == 1 {
            if weekDaysArrayForTracker.count == 7 {
                cell.configureDescriptionLable(textDescriptionLable: "Каждый день")
            } else {
                cell.configureDescriptionLable(textDescriptionLable: weekdaysForTracker)
            }
        }
        cell.backgroundColor = .backgroundDay
        return cell
    }
}

extension HabitOrEventViewController: CategoryViewControllerDelegateForHabit {
    func categoryIsPicket(category: String) {
        categoryForTracker = category
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}

extension HabitOrEventViewController: ScheduleViewControllerDelegate {
    func weekdaysIsPicked(weekDaysArray: [WeekDay]) {
        weekDaysArrayForTracker = weekDaysArray
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}
