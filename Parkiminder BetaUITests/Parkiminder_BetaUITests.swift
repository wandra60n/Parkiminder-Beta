//
//  Parkiminder_BetaUITests.swift
//  Parkiminder BetaUITests
//
//  Created by dading on 17/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import XCTest

class Parkiminder_BetaUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // stop immediately after failure
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    // test the CustomTimerView, make sure it switches mode correctly and dismissed if tapped outside
    func testCustomTimerView() {
        // since simulator doesn't have hardware camera, alert is shown, then dismiss is tapped
        let nocameraAlert = app.alerts["No Camera"]
        if nocameraAlert.exists {
            nocameraAlert.scrollViews.otherElements.buttons["Dismiss"].tap()
        }
        // tap custom timer button
        app.buttons["icon stopwatch"].tap()
        let setButton = app.buttons["SET"]
        // assert custom timer button exists
        XCTAssertTrue(setButton.exists == true)
        
        let dateMode = app.segmentedControls.buttons["Pick date"]
        let timerMode = app.segmentedControls.buttons["Set timer"]
        var numberOfWheels = 0
        // tap Pick Date
        dateMode.tap()
        // assert picker mode is changed from timer to date
        numberOfWheels = app.datePickers.pickerWheels.count
        // picker has at least 3 components i.e. date, hour and minute
        XCTAssertTrue(numberOfWheels >= 3)
        // tap set timer
        timerMode.tap()
        // picker has 2 components i.e. hour and minute
        numberOfWheels = app.datePickers.pickerWheels.count
        XCTAssertTrue(numberOfWheels == 2)
       
        // random point x=40 y=40 outside the custom timer view
        let offPickerArea = app.children(matching: .window).element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 40, dy: 40))
        // tap any point
        offPickerArea.tap()
        // assert custom timer view is dismiss when any point is tapped
        XCTAssertTrue(setButton.exists == false)
        
    }
    
    // this function tests navigating from main View to CountDownView
    func testCountDownView() {
        // since simulator doesn't have hardware camera, alert is shown, then dismiss is tapped
        let nocameraAlert = app.alerts["No Camera"]
        if nocameraAlert.exists {
            nocameraAlert.scrollViews.otherElements.buttons["Dismiss"].tap()
        }
        // tap 30 mins button
        let thirtyMinsButton = app.collectionViews.staticTexts["30"]
        thirtyMinsButton.tap()
        let imhereButton = app.staticTexts["I'm Here"]
        // test app navigate to CountDownView
        XCTAssertTrue(imhereButton.exists)
        imhereButton.tap()
        // test app navigate back to main View
        XCTAssertFalse(imhereButton.exists)
        XCTAssertTrue(thirtyMinsButton.exists)
        // navigate to HistoryView and make sure just created record exists
        let historyButton = app.buttons["icon menu"]
        historyButton.tap()
        let createdRecord = app.tables.cells.staticTexts["30m"]
        XCTAssertTrue(createdRecord.exists)
    }
    
    // test navigate from main View to HistoryView
    func testTapHistory() {
        // since simulator doesn't have hardware camera, alert is shown, then dismiss is tapped
        let nocameraAlert = app.alerts["No Camera"]
        if nocameraAlert.exists {
            nocameraAlert.scrollViews.otherElements.buttons["Dismiss"].tap()
        }
        
        let historyButton = app.buttons["icon menu"]
        
        historyButton.tap()
        XCTAssertTrue(historyButton.exists)
        
        let tablesQuery = app.tables
        let thisMonthSection = tablesQuery.otherElements["This Month"]
        XCTAssertTrue(thisMonthSection.staticTexts["This Month"].exists)
        
        let deleteSectionButton = thisMonthSection.buttons["icon bin"]
        if deleteSectionButton.isEnabled {
            deleteSectionButton.tap()
            app.alerts["Clear records for This Month?"].scrollViews.otherElements.buttons["Yes"].tap()
            let nodataCell = app.staticTexts["No Data"]
            XCTAssertTrue(nodataCell.exists)
        }
        
        let backButton = app.buttons["icon leftcircle"]
        backButton.tap()
        
        XCTAssertFalse(thisMonthSection.exists)
        XCTAssertTrue(historyButton.exists)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
