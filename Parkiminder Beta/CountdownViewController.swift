//
//  CountdownViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 27/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMaps

class CountdownViewController: UIViewController {

    var countdownTask: Reminder!
    var timer: Timer?
    var durationLeft: Int?
//    var localNotificationsManager: LocalNotificationsManager?
    
    @IBOutlet weak var ibTimeLabel: UILabel!
    @IBOutlet weak var ibImagePreview: UIImageView!
    @IBOutlet weak var ibDescriptionLabel: UILabel!
    @IBOutlet weak var ibDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        refreshView()
        self.ibDoneButton.layer.cornerRadius = 10
        self.ibDoneButton.clipsToBounds = true
        
        initAppObserver()
        if countdownTask?.isDue() == false && self.timer == nil {
            durationLeft = Int(countdownTask!.dueTime.timeIntervalSinceNow * 1000)
//            durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
            loadElements()
            runTimer()
        } else {
            print("i am doing nothing now")
        }
        /**
        durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
        if durationLeft! > 0 {
            runTimer()
        }**/
        
    }
    
    func initAppObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func loadElements() {
        // load image preview
        
        if self.countdownTask?.imageData == nil {
            // put default image here
            self.ibImagePreview.contentMode = .scaleAspectFit
            self.ibImagePreview.backgroundColor = .gray
            self.ibImagePreview.image = UIImage(named: "parked_car")
        } else {
            self.ibImagePreview.contentMode = .scaleAspectFill
            self.ibImagePreview.image = UIImage(data: (self.countdownTask?.imageData)!)
        }
        // load text
        self.ibDescriptionLabel.text = self.countdownTask?.description
    }
    
    @objc func applicationDidEnterBackground(notification : NSNotification) {
        print("\(#function)")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        timer?.invalidate()
        
    }
    
    @objc func applicationDidBecomeActive(notification : NSNotification) {
//        print("sneeze")
        print("\(#function)")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        durationLeft = Int(countdownTask!.dueTime.timeIntervalSinceNow * 1000)
        //            durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
        if self.timer?.isValid == false {
            loadElements()
            runTimer()
        }
        // reset the timer display here
        self.ibTimeLabel.text = "00 : 00 : 00"
        
    }
    
    func runTimer() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if durationLeft! >= 0 {
            if durationLeft! % 1000 == 0 {
                ibTimeLabel.text = secsFormatter(time: durationLeft!)
            }
            durationLeft! -= 1
        } else {
//            backToMain()
        }
    }
    
    func secsFormatter(time: Int) -> String {
        let hours = (time/1000) / 3600
        let minutes = (time/1000) / 60 % 60
        let seconds = (time/1000) % 60
        return String(format:"%02d : %02d : %02d", hours, minutes, seconds)
    }
    
    
//    func refreshView() {
//        /**let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        ibTimeLabel.text = formatter.string(from: countdownTask!.dueTime)**/
//
//        durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
//        ibTimeLabel.text = String(durationLeft!)
//    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
//        localNotificationsManager?.clearScheduledNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        backToMain()
    }
    
    func backToMain() {
        timer?.invalidate()
//        UserDefaults.standard.set(false, forKey: "COUNTDOWN_IS_RUNNING")
        countdownTask?.clearFromUDef()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDirectionButton(_ sender: UIButton) {
        
        var mapURL: String = "https://www.google.com/maps/search/?api=1&query="
        mapURL.append(String(self.countdownTask.latitude))
        mapURL.append(",")
        mapURL.append(String(self.countdownTask.longitude))
        UIApplication.shared.open(URL(string: mapURL)!, options: [:], completionHandler: nil)
//        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
//            UIApplication.sharedApplication().openURL(NSURL(string:
//                "comgooglemaps://?saddr=&daddr=\(place.latitude),\(place.longitude)&directionsmode=driving")!)
//
//        } else {
//            NSLog("Can't use comgooglemaps://");
//        }
    }
        
    @IBAction func clickDoneButton(_ sender: UIButton) {
        // persist the reminder, dont forget for nil image
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        countdownTask.persistToCD()
        backToMain()
    }
    //        mapURL.append(String(self.countdownTask?.latitude))
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
