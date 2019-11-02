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
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.createdTime == rhs.createdTime &&
            lhs.dueTime == rhs.dueTime &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.imageData == rhs.imageData &&
            lhs.description == rhs.description
    }
    
    func saveCurrent() -> Bool{
        do {
            let temp = try PropertyListEncoder().encode(self)
            UserDefaults.standard.set(temp, forKey: constantString.keyUserDefaults.rawValue)
            print("\(#function)")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func loadFromUDef() -> Reminder? {
        guard let tempData = UserDefaults.standard.object(forKey: constantString.keyUserDefaults.rawValue) as? Data else {
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
        UserDefaults.standard.removeObject(forKey: constantString.keyUserDefaults.rawValue)
    }
    
    func isDue() -> Bool {
        let delta = dueTime.timeIntervalSinceNow
        if delta <= 0 {
            return true
        } else {
            return false
        }
    }
    
    func persistToCD() {
        /**guard let imageURL = persistImage() as? String else {
            return
        }**/
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let imageURL = persistImage()
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: constantString.entityNameReminder.rawValue, in: managedContext)!
        
        let reminder = NSManagedObject(entity: entity, insertInto: managedContext)
        reminder.setValue(self.createdTime, forKeyPath: constantString.attributeCreatedTime.rawValue)
        reminder.setValue(self.description, forKeyPath: constantString.attributeDescription.rawValue)
        reminder.setValue(self.dueTime, forKeyPath: constantString.attributeDueTime.rawValue)
        reminder.setValue(imageURL, forKeyPath: constantString.attributeImageURL.rawValue)
        reminder.setValue(self.latitude, forKeyPath: constantString.attributeLatitude.rawValue)
        reminder.setValue(self.longitude, forKeyPath: constantString.attributeLongitude.rawValue)
        
        do {
            try managedContext.save()
            print("save to core data successfull")
        } catch {
            print("fail to save to core data")
        }
        
    }
    
    static func retrieveImage(imageURL: String) -> Data? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsPath.appendingPathComponent(imageURL)
        if FileManager.default.fileExists(atPath: imagePath.path) {
            do {
                let imageData = try Data(contentsOf: imagePath)
                return imageData
            } catch {
                print("error retireve data")
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func clearImagePersistance(imageName: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsPath.appendingPathComponent(imageName)
        do {
            try FileManager.default.removeItem(atPath: imagePath.path)
            return true
        } catch {
            print("can not delete image data")
            return false
        }
    }
    
    func persistImage() -> String? {
        if self.imageData == nil {
            return constantString.imageUnavailable.rawValue
        }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFilename = String(self.createdTime.timeIntervalSince1970).replacingOccurrences(of: ".", with: "-") + ".JPEG"
        let imageURL = documentsPath.appendingPathComponent(imageFilename)
        print(imageURL)

        do {
            try self.imageData?.write(to: imageURL)
            return String(imageFilename)
        } catch {
            print("can not save file \(imageURL)")
            return nil
        }
    }
}
