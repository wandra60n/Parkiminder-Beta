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

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func inspect() {
        
    }
    
    
    func testCustomTimerView() {

        // launch the application
        let app = XCUIApplication()
        // since simulator doesn't have hardware camera, alert is shown, then dismiss is tapped
        app.alerts["No Camera"].scrollViews.otherElements.buttons["Dismiss"].tap()
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
        if dateMode.isSelected {
            numberOfWheels = app.datePickers.pickerWheels.count
            XCTAssertTrue(numberOfWheels == 3)
        } else if timerMode.isSelected {
            numberOfWheels = app.datePickers.pickerWheels.count
            XCTAssertTrue(numberOfWheels == 2)
        }
        // any point outside the custom timer view
        let offPickerArea = app.children(matching: .window).element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 40, dy: 40))
        // tap any point
        offPickerArea.tap()
        // assert custom timer view is dismiss when any point is tapped
        XCTAssertTrue(setButton.exists == false)
        
    }
    
    func testSegueFromHome() {
        
        let app = XCUIApplication()
        app.alerts["No Camera"].scrollViews.otherElements.buttons["Dismiss"].tap()
        app.buttons["icon menu"].tap()
        
        let tablesQuery = app.tables
        let thisMonthSection = tablesQuery.otherElements["This Month"].staticTexts["This Month"]
        let last3MonthsSection = tablesQuery.otherElements["Last 3 Months"].staticTexts["Last 3 Months"]
        let moreSection = tablesQuery.otherElements["More"].staticTexts["More"]
        
        
        XCTAssertTrue(thisMonthSection.exists && last3MonthsSection.exists && moreSection.exists)
        
        let backButton = app.buttons["icon leftcircle"]
        backButton.tap()
        
        XCTAssertFalse(thisMonthSection.exists || last3MonthsSection.exists || moreSection.exists)
       
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
