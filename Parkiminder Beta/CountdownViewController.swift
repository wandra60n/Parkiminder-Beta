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
    @IBOutlet weak var ibDoneButton: UIButton!
    @IBOutlet weak var ibNavigateButton: UIButton!
    @IBOutlet weak var ibCapturedView: UIImageView!
    @IBOutlet weak var ibCapturedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ibCapturedViewWidth: NSLayoutConstraint!
    @IBOutlet weak var ibDescriptionViewText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAppObserver()
        
        self.ibDoneButton.makeSquircle()
        self.ibNavigateButton.makeCircle()
        self.ibImagePreview.makeSquircle()
        self.ibDescriptionViewText.makeSquircle()
        
        if countdownTask?.isDue() == false && self.timer == nil {
            durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
            loadElements()
            runTimer()
        } else {
            loadElements()
            self.ibTimeLabel.text = "Parking has ended"
        }
    }
    
    // allowing view to get specified application state from appdelegate
    func initAppObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func previewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "segueToPreview", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // preview image on tap
        if segue.identifier == "segueToPreview" {
            let preview = segue.destination as! PreviewViewController
            preview.capturedImage = UIImage(data: (self.countdownTask?.imageData)!)
            preview.callback_clearCapturedImage = nil
        }
    }
    
    func loadElements() {
        // load map image
        self.ibImagePreview.contentMode = .scaleAspectFit
        self.ibImagePreview.backgroundColor = .gray
        let center = String(self.countdownTask.latitude) + "," + String(self.countdownTask.longitude)
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/staticmap"
        urlComponents.queryItems = [
           URLQueryItem(name: "zoom", value: String(19)),
           URLQueryItem(name: "center", value: center),
           URLQueryItem(name: "size", value: String(Int(ibImagePreview.frame.size.width)) + "x" + String(Int(ibImagePreview.frame.size.height))),
           URLQueryItem(name: "markers", value: "location:" + center),
           URLQueryItem(name: "key", value: GMaps_API_Key)
        ]
        
        self.ibImagePreview.load(url: urlComponents.url!)
        self.ibImagePreview.contentMode = .scaleToFill
        
        // load image preview
        if self.countdownTask?.imageData == nil {
            // make sure image preview is hidden
            self.ibCapturedView.isHidden = true
        } else {
            // load image to preview
            let capturedImage = UIImage(data: (self.countdownTask?.imageData)!)
            self.ibCapturedViewWidth.constant = (capturedImage?.size.width)! * 0.02
            self.ibCapturedViewHeight.constant = (capturedImage?.size.height)! * 0.02
            self.ibCapturedView.isHidden = false
            self.ibCapturedView.contentMode = .scaleAspectFill
            self.ibCapturedView.image = capturedImage
            
            // add tap gesture
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previewTapped(tapGestureRecognizer:)))
            self.ibCapturedView.isUserInteractionEnabled = true
            self.ibCapturedView.addGestureRecognizer(tapGestureRecognizer)
        }
        // load text
        self.ibDescriptionViewText.text = self.countdownTask?.description
//        self.ibDescriptionLabel.text = self.countdownTask?.description
    }
    
    @objc func applicationDidEnterBackground(notification : NSNotification) {
        print("\(#function)")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        timer?.invalidate()
        
    }
    
    @objc func applicationWillTerminate(notification : NSNotification) {
        print("\(#function)")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.countdownTask.saveCurrent()
    }
    
    
    
    @objc func applicationDidBecomeActive(notification : NSNotification) {
        print("\(#function)")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        durationLeft = Int(ceil(countdownTask!.dueTime.timeIntervalSinceNow))
        if self.timer?.isValid == false {
            loadElements()
            runTimer()
        }
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if durationLeft! >= 0 {
            ibTimeLabel.text = Double(durationLeft!).toString()
            durationLeft! -= 1
        } else {
            self.ibTimeLabel.text = "Parking has ended"
        }
    }
    
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        backToMain()
    }
    
    func backToMain() {
        timer?.invalidate()
        countdownTask?.clearFromUDef()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDirectionButton(_ sender: UIButton) {
        var mapURL: String = "https://www.google.com/maps/search/?api=1&query="
        mapURL.append(String(self.countdownTask.latitude))
        mapURL.append(",")
        mapURL.append(String(self.countdownTask.longitude))
        UIApplication.shared.open(URL(string: mapURL)!, options: [:], completionHandler: nil)
    }
        
    @IBAction func clickDoneButton(_ sender: UIButton) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // record the reminder
        countdownTask.persistToCD()
        backToMain()
    }

}


