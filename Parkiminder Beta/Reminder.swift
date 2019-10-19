//
//  Reminder.swift
//  Parkiminder Beta
//
//  Created by dading on 27/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Reminder : Codable, Equatable {
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.createdTime == rhs.createdTime &&
            lhs.dueTime == rhs.dueTime &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.imageData == rhs.imageData &&
            lhs.description == rhs.description
    }
    
    
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
    
    /**
     init() { // dummy implementation only
        self.createdTime = Date()
        self.dueTime = createdTime + 15
        self.latitude = -37.808163434
        self.longitude = 144.957829502
        self.imageData = nil
        self.description = "this is Melbourne"
    }**/
    
    func saveCurrent() -> Bool{
        do {
            let temp = try PropertyListEncoder().encode(self)
            UserDefaults.standard.set(temp, forKey: constantString.forUserDefaults.rawValue)
            print("\(#function)")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func loadFromUDef() -> Reminder? {
        guard let tempData = UserDefaults.standard.object(forKey: constantString.forUserDefaults.rawValue) as? Data else {
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
        UserDefaults.standard.removeObject(forKey: constantString.forUserDefaults.rawValue)
    }
    
    func isDue() -> Bool {
        let delta = dueTime.timeIntervalSinceNow // maybe ceil this into seconds first
        if delta <= 0 {
            return true
        } else {
            return false
        }
    }
    
    func persistToCD() {
        guard let imageURL = persistImage() as? String else {
            return
        }
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        //            let imageFilename = String(self.createdTime.timeIntervalSince1970).replacingOccurrences(of: ".", with: "-") + ".JPEG"
//        let imagePath = documentsPath.appendingPathComponent(imageURL)
////        print(imagePath)
//        print(FileManager.default.fileExists(atPath: imagePath.path))
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Reminder_CD", in: managedContext)!
        
        let reminder = NSManagedObject(entity: entity, insertInto: managedContext)
        reminder.setValue(self.createdTime, forKeyPath: "createdTime_Date")
        reminder.setValue(self.description, forKeyPath: "description_String")
        reminder.setValue(self.dueTime, forKeyPath: "dueTime_Date")
        reminder.setValue(imageURL, forKeyPath: "imageurl_String")
        reminder.setValue(self.latitude, forKeyPath: "latitude_Double")
        reminder.setValue(self.longitude, forKeyPath: "longitude_Double")
        
        do {
            try managedContext.save()
            print("save to core data successfull")
        } catch {
            print("fail to save to core data")
        }
        
    }
    
    
    
    func persistImage() -> String? {
        
        if self.imageData == nil {
            return "IMAGE_NOT_AVAILABLE"
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFilename = String(self.createdTime.timeIntervalSince1970).replacingOccurrences(of: ".", with: "-") + ".JPEG"
        let imageURL = documentsPath.appendingPathComponent(imageFilename)
        print(imageURL)
//        let imageFIle = UIImage(data: self.imageData!)
//        print(imageFIle?.size)
        
        do {
            try self.imageData?.write(to: imageURL)
//            print(String(imageFilename))
            return String(imageFilename)
        } catch {
            print("can not save file \(imageURL)")
            return nil
        }
    }
}
