//
//  Reminder.swift
//  Parkiminder Beta
//
//  Created by dading on 27/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import Foundation

class Reminder : Codable{
    
    let createdTime: Date
    let dueTime: Date
    let latitude: Double
    let longitude: Double
    let imageData: Data?
    let description: String
    
    init(createdTime: Date, dueTime: Date, latitude: Double, longitude: Double, imageData: Data? , description: String) {
        self.createdTime = createdTime
        self.dueTime = dueTime
        self.latitude = latitude
        self.longitude = longitude
        self.imageData = imageData
        self.description = description
    }
    
    init() { // dummy implementation only
        self.createdTime = Date()
        self.dueTime = createdTime + 15
        self.latitude = -37.808163434
        self.longitude = 144.957829502
        self.imageData = nil
        self.description = "this is Melbourne"
    }
    
    func saveCurrent() -> Bool{
        do {
            let temp = try PropertyListEncoder().encode(self)
            UserDefaults.standard.set(temp, forKey: "RUNNING_COUNTDOWN")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func loadFromUDef() -> Reminder? {
        guard let tempData = UserDefaults.standard.object(forKey: "RUNNING_COUNTDOWN") as? Data else {
            return nil
        }
        do {
            let temp = try PropertyListDecoder().decode(Reminder.self, from: tempData)
            return temp
        } catch {
            print(error)
            return nil
        }
    }
    
    func clearFromUDef() {
        UserDefaults.standard.removeObject(forKey: "RUNNING_COUNTDOWN")
    }
    
    func isDue() -> Bool {
        let delta = dueTime.timeIntervalSinceNow // maybe ceil this into seconds first
        if delta <= 0 {
            return true
        } else {
            return false
        }
    }
}
