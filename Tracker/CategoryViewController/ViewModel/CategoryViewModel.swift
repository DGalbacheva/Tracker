//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Doroteya Galbacheva on 18.11.2024.
//

import Foundation

protocol CategoryViewModelDelegate: AnyObject {
    func categoryIsPicked(category: String)
}

final class CategoryViewModel {
    
    weak var delegate: CategoryViewModelDelegate?
    private let trackerCategoryStore = TrackerCategoryStore()
    var categories: [String] = [] {
        didSet {
            updateTableViewClosure?()
        }
    }
    
    var updateTableViewClosure: (() -> Void)?
    
    init() {
        updateCategory()
    }
    
    func updateCategory() {
        let category = trackerCategoryStore.getTrackerCategoryFromDB()
        var title: [String] = []
        for i in category {
            title.append(i.title)
        }
        self.categories = title
    }
    
    func categoryIsPicked(category: String) {
        delegate?.categoryIsPicked(category: category)
    }
}

extension CategoryViewModel: CreateCategoryViewControllerDelegate {
    func getCategoryFromModel() {
        updateCategory()
    }
}
