//
//  LocalNotificationsManager.swift
//  Parkiminder Beta
//
//  Created by dading on 28/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationsManager {
    var notifications = [Notification]()
    
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    func clearScheduledNotifications() {
        print("\(#function)")
        var arrayNotificationsID = [String]()
        for notification in self.notifications {
            arrayNotificationsID.append(notification.id)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: arrayNotificationsID)
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    
    func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else {
                    return
                }
            }
        }
        print("\(#function) success")
    }
}

struct Notification {
    var id:String
    var title:String
    var datetime:DateComponents
}
