//
//  CustomTimerViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 29/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit

class CustomTimerViewController: UIViewController {

    @IBOutlet weak var ibModeLabel: UILabel!
    @IBOutlet weak var ibDatePicker: UIDatePicker!
    @IBOutlet weak var ibModeSwitch: UISwitch!
    
    var callback_createReminder: ((Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dismissViewWhenTappedAround()
        initModeTimer()
    }
    
    @IBAction func clickCreateButton(_ sender: UIButton) {
        dismiss(animated: true) {
//            self.callback_createReminder!(temp!)
            if self.ibModeSwitch.isOn { // countdown mode
                self.callback_createReminder!(self.ibDatePicker.countDownDuration)
            } else {
                print("(\(#function)) \(self.ibDatePicker.date)")
                self.callback_createReminder!(self.ibDatePicker.date.timeIntervalSinceNow)
            }
        }
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickModeSwitch(_ sender: UISwitch) {
        if ibModeSwitch.isOn {
            initModeTimer()
        } else {
            initModeDate()
        }
    }
    
    func initModeTimer() {
        ibModeLabel.text = "Timer"
        ibDatePicker.datePickerMode = .countDownTimer
//        ibDatePicker.timeZone = .autoupdatingCurrent
        ibDatePicker.countDownDuration = 30*60
        ibDatePicker.minuteInterval = 10
        ibDatePicker.minimumDate = Date() + 10*60
    }
    
    func initModeDate() {
        ibModeLabel.text = "Pick Time"
        ibDatePicker.datePickerMode = .dateAndTime
//        ibDatePicker.calendar = .current
//        ibDatePicker.timeZone = .autoupdatingCurrent
//        ibDatePicker.minuteInterval = 10
        ibDatePicker.minimumDate = Date()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    // tap anywhere to hide keyboard
    func dismissViewWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissView))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}


