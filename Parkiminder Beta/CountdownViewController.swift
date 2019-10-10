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
    @IBOutlet weak var ibNavigateButton: UIButton!
    @IBOutlet weak var ibCapturedView: UIImageView!
    @IBOutlet weak var ibCapturedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ibCapturedViewWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        refreshView()
        self.ibDoneButton.layer.cornerRadius = 10
        self.ibDoneButton.clipsToBounds = true
        self.ibNavigateButton.makeCircle()
        self.ibImagePreview.makeSquircle()
        
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
    
    @objc func previewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
//        print(tappedImage.frame.size)
        
        performSegue(withIdentifier: "segueToPreview", sender: self)

        // Your action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToPreview" { // for moving to review
            let preview = segue.destination as! PreviewViewController
            preview.capturedImage = UIImage(data: (self.countdownTask?.imageData)!)
            /**preview.callback_clearCapturedImage = { [weak self] in
                self?.clearCapturedImage()
            }**/
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
           URLQueryItem(name: "key", value: "AIzaSyD9ALgOo2K3162mroiad8r6xE9wr-Hhh8s")
        ]
        
        self.ibImagePreview.load(url: urlComponents.url!)
        self.ibImagePreview.contentMode = .scaleToFill
        
        // load image preview
        
        if self.countdownTask?.imageData == nil {
            // make sure image preview is hidden
            self.ibCapturedView.isHidden = true
            /**
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
               URLQueryItem(name: "key", value: "AIzaSyD9ALgOo2K3162mroiad8r6xE9wr-Hhh8s")
            ]
            
            self.ibImagePreview.load(url: urlComponents.url!)
            self.ibImagePreview.contentMode = .scaleToFill**/
//            self.ibImagePreview.image = UIImage()
//            let mapUrl: NSURL = NSURL(string: staticMapUrl)!
//            self.imgViewMap.sd_setImage(with: mapUrl as URL, placeholderImage: UIImage(named: "palceholder"))
        } else {
//            self.ibImagePreview.contentMode = .scaleAspectFill
//            self.ibImagePreview.image = UIImage(data: (self.countdownTask?.imageData)!)
            
            let capturedImage = UIImage(data: (self.countdownTask?.imageData)!)
            self.ibCapturedViewWidth.constant = (capturedImage?.size.width)! * 0.02
            self.ibCapturedViewHeight.constant = (capturedImage?.size.height)! * 0.02
            self.ibCapturedView.isHidden = false
            self.ibCapturedView.contentMode = .scaleAspectFill
            self.ibCapturedView.image = capturedImage
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previewTapped(tapGestureRecognizer:)))
            self.ibCapturedView.isUserInteractionEnabled = true
            self.ibCapturedView.addGestureRecognizer(tapGestureRecognizer)
//            self.ibImagePreview.image = capturedImage
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    print("invalid image data retrieved")
                    return
                }
                DispatchQueue.main.async {
                    self?.image = image
                    print("static map loaded")
                }
            } catch {
                print("url error")
                return
            }
            /**if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        print("static map loaded")
                    }
                }
            }**/
        }
    }
}
