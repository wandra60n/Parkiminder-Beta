//
//  ViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 27/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var tempReminder: Reminder?
    var tempLatitude: Double?
    var tempLongitude: Double?
    var tempImage: UIImage?
    var isCameraAvailable: Bool?
    
    private let locationManager = CLLocationManager()
    private let default_image = UIImage(named: "icon_camera")
    private let hotButtons: [Double] = [30*60, 60*60, 90*60, 120*60]
    
    @IBOutlet weak var ibMapView: GMSMapView!
    @IBOutlet weak var ibDescriptionText: UITextView!
    @IBOutlet weak var ibCameraButton: UIButton!
    @IBOutlet weak var ibHistoryButton: UIButton!
    @IBOutlet weak var ibCustomTimerButton: UIButton!
    @IBOutlet weak var ibButtonCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // CLLocationManagerDelegate
        
        
        applyStyling()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // GMSMapViewDelegate
        ibMapView.delegate = self
        
        // flag if device has camera
        isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // keyboard stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        // uncomment this to create dummy reminders with nil image
//        initiateDummyReminders(x: 3, y: 4, z: 5)
        ibButtonCollectionView.dataSource = self
        ibButtonCollectionView.delegate = self
    }
    
    func applyStyling() {
        ibHistoryButton.makeSquircle()
//        ibHotAButton.makeSquircle()
//        ibHotBButton.makeSquircle()
//        ibHotCButton.makeSquircle()
        ibCustomTimerButton.makeSquircle()
        ibCameraButton.makeSquircle()
        ibDescriptionText.makeSquircle()
        ibMapView.makeSquircle()
        ibButtonCollectionView.makeSquircle()
    }
    
    /**func makeButtonRound() {
        self.ibHotAButton.layer.cornerRadius = 10
        self.ibHotAButton.clipsToBounds = true
        self.ibHotBButton.layer.cornerRadius = 10
        self.ibHotBButton.clipsToBounds = true
        self.ibHotCButton.layer.cornerRadius = 10
        self.ibHotCButton.clipsToBounds = true
    }**/
    
    override func viewDidAppear(_ animated: Bool) {
        checkCameraPresent()
        
        self.tempReminder = Reminder.loadFromUDef()
        if tempReminder != nil { // check if user defaults has reminder
            performSegue(withIdentifier: "segueToCountdown", sender: self)
//            if (tempReminder?.isDue())! {
//                tempReminder?.clearFromUDef()
//            } else {
//                performSegue(withIdentifier: "segueToCountdown", sender: self)
//            }
        }
        /**
        checkCameraPresent()
        print("\(#function)")
        /** this creates BUG
        if checkRunning() {
            // segue to Countdown View
            segueToCountdown()
        }**/
        
        if isReminderActive() {
            print("how could this be")
            performSegue(withIdentifier: "segueToCountdown", sender: self)
        }**/
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func isReminderActive() -> Bool{
        if Reminder.loadFromUDef() == nil {
            return false
        } else {
            return true
        }
    }
    
    /** this cause bug
    func checkRunning() -> Bool{
        let countdownIsRunning = UserDefaults.standard.bool(forKey: "COUNTDOWN_IS_RUNNING")
//        print("\(#function) \(countdownIsRunning)")
        return countdownIsRunning
    }**/
    
    func checkCameraPresent() {
        if !isCameraAvailable! {
            let alert = UIAlertController(title: "No Camera", message: "Camera hardware unavailable", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    @IBAction func clickCameraButton(_ sender: UIButton) {
//        let default_image = UIImage(named: "icon_camera")
        let capturedImageIsEmpty = ibCameraButton.currentImage == default_image
        if capturedImageIsEmpty {
            takePicture()
        } else {
            performSegue(withIdentifier: "segueToPreview", sender: self)
        }
    }
    
    func takePicture() {
        if isCameraAvailable! {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.camera
//            picker.cameraDevice = UIImagePickerController.CameraDevice.front
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func clickCustomButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToCustomTimer", sender: self)
    }
    
    
    @IBAction func clickSetButton(_ sender: UIButton) {
        self.tempReminder = Reminder.loadFromUDef()
        if tempReminder == nil {
//            test_last5secs()
            createReminder(secondsInterval: 15.0)
//            createReminder(dueTime: Date())
        }
//        tempReminder!.saveCurrent()
//        segueToCountdown()
    }
    
    func segueToCountdown() {
//        checkRunning()
//        UserDefaults.standard.set(true, forKey: "COUNTDOWN_IS_RUNNING")
        performSegue(withIdentifier: "segueToCountdown", sender: self)
        clearCapturedImage()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCountdown" { // for moving to countdown
            let countdown = segue.destination as! CountdownViewController
            countdown.countdownTask = tempReminder
        } else if segue.identifier == "segueToPreview" { // for moving to review
            let preview = segue.destination as! PreviewViewController
            preview.capturedImage = self.tempImage
            /**preview.callback_clearCapturedImage = { [weak self] in
                self?.clearCapturedImage()
            }**/
            preview.callback_clearCapturedImage = self.clearCapturedImage
        } else if segue.identifier == "segueToCustomTimer" {
            let customTimer = segue.destination as! CustomTimerViewController
            customTimer.callback_createReminder = self.createReminder
        }
    }
    
    func clearCapturedImage() {
        self.tempImage = nil
        ibCameraButton.setImage((default_image), for: .normal)
    }
    
    
    func createReminder(secondsInterval: Double) {
        print("\(#function) \(secondsInterval)")
        
        // schedule reminder first!
        
        
        let capturedImageIsEmpty = ibCameraButton.currentImage == default_image
        let dateNow = Date()
        
        if capturedImageIsEmpty {
            tempReminder = Reminder(createdTime: dateNow, dueTime: dateNow + secondsInterval, latitude: self.tempLatitude!, longitude: self.tempLongitude!, imageData: nil, description: self.ibDescriptionText.text)
        } else {
            tempReminder = Reminder(createdTime: dateNow, dueTime: dateNow + secondsInterval, latitude: self.tempLatitude!, longitude: self.tempLongitude!, imageData: (self.tempImage?.jpegData(compressionQuality: 1.0))!, description: self.ibDescriptionText.text)
        }
        
        scheduleNotifications()
        
        /**var localNotificationsManager = LocalNotificationsManager()
        let tempDate = tempReminder!.dueTime - 5
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: tempDate)
        
        localNotificationsManager.notifications = [Notification(id: "LAST_5_SEC_NOTIFICATION", title: "Parking End in 5 Sec", datetime: components)]
        localNotificationsManager.schedule()**/
        
        tempReminder!.saveCurrent()
        segueToCountdown()
        
    }
    
    func scheduleNotifications() {
        var durationTuples:[(id: String, duration: Double)] = []
        durationTuples.append((id: "PARKING_ENDED", duration: 0*60))
        durationTuples.append((id: "LAST_5_MINS", duration: 5*60))
        durationTuples.append((id: "LAST_15_MINS", duration: 15*60))
        durationTuples.append((id: "LAST_30_MINS", duration: 30*60))
        
        var localNotificationsManager = LocalNotificationsManager()
        for tuple in durationTuples {
            let notificationDate = tempReminder!.dueTime - tuple.duration
            if  notificationDate > tempReminder!.createdTime {
                let components = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: notificationDate)
                var notificationTitle = "Parking end in "
                if tuple.duration > 0 {
                    notificationTitle += tuple.duration.toString()
                } else {
                    notificationTitle = "Parking has ended"
                }
                localNotificationsManager.notifications.append(Notification(id: tuple.id, title: notificationTitle, descrption: tempReminder!.description, datetime: components))
            }
        }
        localNotificationsManager.schedule()
    }
    
    
    func initiateDummyReminders(x: Int, y: Int, z: Int) {
        // today is 19 Sept 2019
        //random area melb (long lat) 144.959963,-37.82016,144.980037,-37.799924
        
        let minLat = -37.82016; let maxLat = -37.799924
        let minLong = 144.959963; let maxLong = 144.980037
        
        var dateArray: [Date] = []
        var c = x // 5 records for this month
        let tday = Date()
        while c > 0 {
            dateArray.append(tday.randomDatetimeFrom(prevMos: 0))
            c -= 1
        }
        
        c = y
        while c > 0 {
            dateArray.append((Calendar.current.date(byAdding: .month, value: -1, to: tday)?.randomDatetimeFrom(prevMos: 2))!)
            c -= 1
        }
        
        c = z
        while c > 0 {
            dateArray.append((Calendar.current.date(byAdding: .month, value: -3, to: tday)?.randomDatetimeFrom(prevMos: 5))!)
            c -= 1
        }
//        print(dateArray.count)
//        print(dateArray)
        for date in dateArray {
            let tempLat = Double.random(in: minLat...maxLat)
            let tempLong = Double.random(in: minLong...maxLong)
            
            let geoCoder = GMSGeocoder()
            // Asks the geocoder to reverse geocode the coordinate passed to the method.
            geoCoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: tempLat, longitude: tempLong)) { response, error in guard let address = response?.firstResult(), let lines = address.lines else {
                return
                }
//                let description =
                let tempReminder = Reminder(
                    createdTime: date,
                    dueTime: date.addingTimeInterval(Double.random(in: 600...172800)),
                    latitude: tempLat,
                    longitude: tempLong, imageData: nil,
                    description: lines.joined(separator: "\n"))
                tempReminder.persistToCD()
            }
            
//            let tempReminder = Reminder(
//                createdTime: date,
//                dueTime: date.addingTimeInterval(Double.random(in: 600...172800)),
//                latitude: tempLat,
//                longitude: tempLong, imageData: nil, description: reverseGeoCode(longitude: tempLong, latitude: tempLat))
//            tempReminder.persistToCD()
////            print("done")
        }
    }
    
    
    
    
    /**func test_last5secs() {
        // dummy 15 secs reminder
        tempReminder = Reminder()
        // create reminder 5 seconds before duetime
        var localNotificationsManager = LocalNotificationsManager()
        let tempDate = tempReminder!.dueTime - 5
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: tempDate)
        
        localNotificationsManager.notifications = [Notification(id: "LAST_5_SEC_NOTIFICATION", title: "Parking End in 5 Sec", datetime: components)]
        localNotificationsManager.schedule()
        
//        UserDefaults.standard.set(true, forKey: "COUNTDOWN_IS_RUNNING")
        // countdown.localNotificationsManager = localNotificationsManager
    }**/
    @IBAction func clickHistoryButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToHistory", sender: self)
    }
    
}



extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateCurrentPos(position.target)
    }
    
    private func updateCurrentPos(_ coordinate: CLLocationCoordinate2D) {
        print("lat: \(coordinate.latitude) ; long: \(coordinate.longitude)")
        self.tempLatitude = coordinate.latitude
        self.tempLongitude = coordinate.longitude
        
        
        
        // object to turn a latitude and longitude coordinate into a street address.
        let geoCoder = GMSGeocoder()
        
        // Asks the geocoder to reverse geocode the coordinate passed to the method.
        geoCoder.reverseGeocodeCoordinate(coordinate) { response, error in guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.ibDescriptionText.text = lines.joined(separator: "\n")
        }
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        guard status == .authorizedWhenInUse else {
            return
        }
        // Once permissions have been established, ask the location manager for updates on the user’s location.
        locationManager.startUpdatingLocation()
        // draws a light blue dot where the user is located
        ibMapView.isMyLocationEnabled = true
        // button to center the map on the user’s location
        ibMapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        ibMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 19, bearing: 0, viewingAngle: 0)
        
        // only get initial location, then stop
        locationManager.stopUpdatingLocation()
        print("initial location lat: \(location.coordinate.latitude) ; long: \(location.coordinate.longitude)")
        self.tempLatitude = location.coordinate.latitude
        self.tempLongitude = location.coordinate.longitude
        
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let capturedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
            // set preview to button
            ibCameraButton.contentMode = .scaleToFill
            ibCameraButton.setImage(capturedImage, for: .normal)
            tempImage = capturedImage
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    // this is required to call camera
}

extension UIViewController {
    // tap anywhere to hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HotButton", for: indexPath) as! ButtonCollectionViewCell
        
        cell.ibValueLabel.text = String(format:"%.0f", hotButtons[indexPath.item]/60)
        cell.makeSquircle()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        createReminder(secondsInterval: hotButtons[indexPath.item])
    }
}

extension UIView {
    func makeCircle() {
        self.layer.cornerRadius = self.frame.width / 2
    }
//    func putShadow() {
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        self.layer.masksToBounds = false
//        self.layer.shadowRadius = 1.0
//        self.layer.shadowOpacity = 0.5
//    }
    func makeSquircle() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}

extension Double {
    func toString() -> String {
        let formatter = DateComponentsFormatter()

        if Int(self*1000/86400000) > 0 {
//            print("day style")
            formatter.allowedUnits = [.day, .hour]
            formatter.unitsStyle = .brief
        } else if Int(self*1000/3600000) > 0 {
//            print("hour style")
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .brief
        } else if Int(self*1000/60000) > 0 {
//            print("minute style")
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .brief
        } else {
//            print("second style")
            formatter.allowedUnits = [.second]
            formatter.unitsStyle = .brief
        }

        return formatter.string(from: self)!
    }
}
