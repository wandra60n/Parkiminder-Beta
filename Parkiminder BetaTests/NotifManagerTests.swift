//
//  NotifManagerTests.swift
//  Parkiminder BetaTests
//
//  Created by dading on 22/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import XCTest
@testable import Parkiminder_Beta

class NotifManagerTests: XCTestCase {
    var sut: LocalNotificationsManager!
    var pendingcount: Int!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = LocalNotificationsManager()
        initsetup()
    }
    
    func initsetup() {
        let dateNow = Date()
        var testDates: [Date] = []
        testDates.append(dateNow + (10 * 60))
        testDates.append(dateNow + (20 * 60))
        testDates.append(dateNow + (60 * 60))
        
        for date in testDates {
            let components = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)
            sut.notifications.append(Notification(id: String(Date().timeIntervalSince1970), title: "Notification Title", descrption: "Notification Reminder", datetime: components))
        }
        pendingcount = testDates.count
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.clearScheduledNotifications()
        sut = nil
        pendingcount = nil
        super.tearDown()
    }

    func testScheduling() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = self.expectation(description: "scheduling notifications")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.sut.schedule()
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        sut.notificationCenter.getPendingNotificationRequests { (notifications) in
            let notifN = notifications.count
            XCTAssertTrue(notifN == self.pendingcount)
            XCTAssertFalse(notifN == self.pendingcount + 1)
        }
    }
}
