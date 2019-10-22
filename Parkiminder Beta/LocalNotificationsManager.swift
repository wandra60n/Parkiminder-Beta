//
//  LocalNotificationsManager.swift
//  Parkiminder Beta
//
//  Created by dading on 28/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

class LocalNotificationsManager {
    
    var notifications: [Notification]
    var notificationCenter: UNUserNotificationCenter
    
    init() {
        notifications = [Notification]()
        notificationCenter = UNUserNotificationCenter.current()
    }
    
    func clearScheduledNotifications() {
        print("\(#function)")
        notificationCenter.removeAllPendingNotificationRequests()
        /**var arrayNotificationsID = [String]()
        for notification in self.notifications {
            arrayNotificationsID.append(notification.id)
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: arrayNotificationsID)**/
    }
    
    func listScheduledNotifications() {
        print("\(#function)")
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            print("jumlah: " + String(notifications.count))
            for notification in notifications {
                print(notification.content.title)
            }
        }
    }
    
    private func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule() {
        notificationCenter.getNotificationSettings { settings in
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
    
    func scheduleNotifications() -> Bool {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default
            content.body = notification.descrption
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            notificationCenter.add(request) { (error) in
                guard error == nil else {
                    return
                }
            }
        }
        print("\(#function) success")
        return true
    }
}

// creating struct instead of class, only need object to hold attribute
struct Notification {
    var id: String
    var title: String
    var descrption: String
    var datetime: DateComponents
}
