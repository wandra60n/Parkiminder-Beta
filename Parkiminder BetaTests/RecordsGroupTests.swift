//
//  RecordsGroupTests.swift
//  Parkiminder BetaTests
//
//  Created by dading on 19/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import XCTest
@testable import Parkiminder_Beta

class RecordsGroupTests: XCTestCase {
    var testGroup: RecordsGroup!
    let recordNum = 7
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        initDummyGroup()
    }
    
    func initDummyGroup() {
        let dateNow = Date()
        let dueTime = dateNow + (10 * 60)
        let latitude = -37.814
        let longitude = 144.96332
        let desc = "Melbourne, Australia"
        let imageData = UIImage(named: "icon_history")?.jpegData(compressionQuality: 1.0)
        
        for i in 0..<recordNum {
            Reminder(createdTime: dateNow, dueTime: dueTime, latitude: latitude, longitude: longitude, imageData: imageData, description: desc).persistToCD()
        }
        testGroup = RecordsGroup(title: "Temp Group", collapsed: false)
        testGroup.records = HistoryViewController().fetchReminders()
    }
    

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        testGroup = nil
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // given
        XCTAssertTrue(testGroup.records.count == recordNum)
        // when
        testGroup.clearRecords()
        // then
        XCTAssertTrue(testGroup.records.count == 0)
    }


}
