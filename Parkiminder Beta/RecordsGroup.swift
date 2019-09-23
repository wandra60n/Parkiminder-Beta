//
//  RecordsGroup.swift
//  Parkiminder Beta
//
//  Created by dading on 23/9/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RecordsGroup {
    var title: String
    var records: [NSManagedObject]
    var collapsed: Bool
    
    init(title: String, collapsed: Bool) {
        self.title = title
        self.records = []
        self.collapsed = collapsed
    }
    
    func clearRecords() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("mayday mayday")
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for record in records {
            managedContext.delete(record)
        }
        do {
            try managedContext.save()
            self.records = []
        } catch {
            return false
        }
        return true
    }
}
