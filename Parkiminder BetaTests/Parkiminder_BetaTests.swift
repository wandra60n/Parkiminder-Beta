//
//  Parkiminder_BetaTests.swift
//  Parkiminder BetaTests
//
//  Created by dading on 16/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import XCTest
@testable import Parkiminder_Beta

class Parkiminder_BetaTests: XCTestCase {
    var reminder_before: Reminder!
    var reminder_after: Reminder!
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let dateNow = Date()
        let dueTime = dateNow + (10 * 60)
        let latitude = -37.814
        let longitude = 144.96332
        let desc = "Melbourne, Australia"
        let imageData = UIImage(named: "icon_history")?.jpegData(compressionQuality: 1.0)
        
        reminder_before = Reminder(createdTime: dateNow, dueTime: dueTime, latitude: latitude, longitude: longitude, imageData: imageData, description: desc)
        reminder_after = nil
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        reminder_before = nil
        reminder_after = nil
        super.tearDown()
    }

    func testSaveToUserdefault() {
        // given
        // when
        reminder_before.saveCurrent()
        reminder_after = Reminder.loadFromUDef()
        // then
        XCTAssertEqual(self.reminder_before, self.reminder_after)
    }
    
    func testClearFromUDef() {
        // given
        reminder_before.saveCurrent()
        // when
        reminder_before.clearFromUDef()
        reminder_after = Reminder.loadFromUDef()
        // then
        XCTAssertEqual(self.reminder_after, nil)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
