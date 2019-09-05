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
    
    @IBOutlet weak var ibMapView: GMSMapView!
    @IBOutlet weak var ibDescriptionText: UITextView!
    
    @IBOutlet weak var ibDebugLabel: UILabel!
    @IBOutlet weak var ibCameraButton: UIButton!
    
    @IBOutlet weak var ibHotAButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // CLLocationManagerDelegate
        makeButtonRound()
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
        
        
    }
    
    func makeButtonRound() {
        self.ibHotAButton.layer.cornerRadius = 10
        self.ibHotAButton.clipsToBounds = true
    }
    
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
        let default_image = UIImage(named: "camera")
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
        ibCameraButton.setImage(UIImage(named: "camera"), for: .normal)
    }
    
    
    @IBAction func clickHotAButton(_ sender: UIButton) {
        // 30 mins by default
        createReminder(secondsInterval: 30 * 60.0)
//        tempReminder!.saveCurrent()
//        segueToCountdown()
    }
    
    @IBAction func clickHotBButton(_ sender: UIButton) {
        // 60 mins by default
        createReminder(secondsInterval: 60 * 60.0)
//        tempReminder!.saveCurrent()
//        segueToCountdown()
    }
    
    @IBAction func clickHotCButton(_ sender: UIButton) {
        // 120 mins by default
        createReminder(secondsInterval: 120 * 60.0)
//        tempReminder!.saveCurrent()
//        segueToCountdown()
    }
    
    func createReminder(secondsInterval: Double) {
        print("\(#function) \(secondsInterval)")
        
        let default_image = UIImage(named: "camera")
        let capturedImageIsEmpty = ibCameraButton.currentImage == default_image
        let dateNow = Date()
        
        if capturedImageIsEmpty {
            tempReminder = Reminder(createdTime: dateNow, dueTime: dateNow + secondsInterval, latitude: self.tempLatitude!, longitude: self.tempLongitude!, imageData: nil, description: self.ibDescriptionText.text)
        } else {
            tempReminder = Reminder(createdTime: dateNow, dueTime: dateNow + secondsInterval, latitude: self.tempLatitude!, longitude: self.tempLongitude!, imageData: (self.tempImage?.jpegData(compressionQuality: 1.0))!, description: self.ibDescriptionText.text)
        }
        
        
        var localNotificationsManager = LocalNotificationsManager()
        let tempDate = tempReminder!.dueTime - 5
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: tempDate)
        
        localNotificationsManager.notifications = [Notification(id: "LAST_5_SEC_NOTIFICATION", title: "Parking End in 5 Sec", datetime: components)]
        localNotificationsManager.schedule()
        
        tempReminder!.saveCurrent()
        segueToCountdown()
    }
    
    func test_last5secs() {
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
        ibMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
        
        // only get initial location, then stop
        locationManager.stopUpdatingLocation()
//        print("initial location lat: \(location.coordinate.latitude) ; long: \(location.coordinate.longitude)")
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
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
