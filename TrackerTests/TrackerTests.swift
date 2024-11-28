//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Doroteya Galbacheva on 25.08.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnapshotTesting.isRecording = false
    }

    func testTrackerViewControllerForEmptyState() {
        let testVC = TrackersViewController()
        let coreDataManager = CoreDataManager.shared
        coreDataManager.trackerCategoryStore.removeAllTrackerCategory()
        coreDataManager.trackerStore.removeAllTrackers()
        coreDataManager.trackerRecordStore.removeAllTrackerRecords()
        assertSnapshot(of: testVC, as: .image)
    }
    
    func testTrackerViewControllerForNormalState() {
        let testVC = TrackersViewController()
        let coreDataManager = CoreDataManager.shared
        coreDataManager.trackerCategoryStore.removeAllTrackerCategory()
        coreDataManager.trackerStore.removeAllTrackers()
        coreDataManager.trackerRecordStore.removeAllTrackerRecords()
        coreDataManager.trackerStore.addNewTracker(tracker: Tracker(id: UUID(), title: "Reading", color: .colorSet1, emoji: "🙌", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]), categoryName: "Book")
        assertSnapshot(of: testVC, as: .image)
    }
}
