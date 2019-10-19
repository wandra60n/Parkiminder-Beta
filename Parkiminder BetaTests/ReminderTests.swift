//
//  Parkiminder_BetaTests.swift
//  Parkiminder BetaTests
//
//  Created by dading on 16/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import XCTest
@testable import Parkiminder_Beta

class ReminderTests: XCTestCase {
    var reminder_before: Reminder!
    var reminder_after: Reminder!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        setDummyReminder()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        reminder_before = nil
        reminder_after = nil
        super.tearDown()
    }
    
    func setDummyReminder() {
        let dateNow = Date()
        let dueTime = dateNow + (10 * 60)
        let latitude = -37.814
        let longitude = 144.96332
        let desc = "Melbourne, Australia"
        let imageData = UIImage(named: "icon_history")?.jpegData(compressionQuality: 1.0)
        
        reminder_before = Reminder(createdTime: dateNow, dueTime: dueTime, latitude: latitude, longitude: longitude, imageData: imageData, description: desc)
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
    
    func testPersistImage() {
        // given
        
        // when
        let tempImageName = reminder_before.persistImage()
        let tempImageData = Reminder.retrieveImage(imageURL: tempImageName!)
        // then
        XCTAssertTrue(tempImageData == reminder_before.imageData)
    }
    
    func testDeleteImage() {
        // given
        
        // when
        let tempImageName = reminder_before.persistImage()
        Reminder.clearImagePersistance(imageName: tempImageName!)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsPath.appendingPathComponent(tempImageName!)
        // then
        XCTAssertFalse(FileManager.default.fileExists(atPath: imagePath.path))
    }

}
