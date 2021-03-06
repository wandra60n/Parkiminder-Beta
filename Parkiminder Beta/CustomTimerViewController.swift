//
//  CustomTimerViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 29/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit

class CustomTimerViewController: UIViewController {

//    @IBOutlet weak var ibModeLabel: UILabel!
    @IBOutlet weak var ibDatePicker: UIDatePicker!
//    @IBOutlet weak var ibModeSwitch: UISwitch!
    @IBOutlet weak var ibPickerSwitch: UISegmentedControl!
    @IBOutlet weak var ibViewContainer: UIView!
    @IBOutlet weak var ibCreateButton: UIButton!
    
    var callback_createReminder: ((Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dismissViewWhenTappedAround()
        ibViewContainer.makeSquircle()
        ibCreateButton.makeSquircle()
        initModeTimer()
    }
    
    @IBAction func clickCreateButton(_ sender: UIButton) {
        dismiss(animated: true) {
//            self.callback_createReminder!(temp!)
            if self.ibPickerSwitch.selectedSegmentIndex == 0 {
                self.callback_createReminder!(self.ibDatePicker.countDownDuration)
            } else {
                self.callback_createReminder!(self.ibDatePicker.date.timeIntervalSinceNow)
            }

        }
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickPickerSwitch(_ sender: UISegmentedControl) {
        switch ibPickerSwitch.selectedSegmentIndex {
        case 0:
            initModeTimer()
        case 1:
            initModeDate()
        default:
            break
        }
    }

    func initModeTimer() {
//        ibModeLabel.text = "Timer"
        ibDatePicker.datePickerMode = .countDownTimer
//        ibDatePicker.timeZone = .autoupdatingCurrent
        ibDatePicker.countDownDuration = 30*60
        ibDatePicker.minuteInterval = 10
        ibDatePicker.minimumDate = Date() + 10*60
    }
    
    func initModeDate() {
//        ibModeLabel.text = "Pick Time"
        ibDatePicker.datePickerMode = .dateAndTime
        ibDatePicker.minuteInterval = 10
//        ibDatePicker.calendar = .current
//        ibDatePicker.timeZone = .autoupdatingCurrent
//        ibDatePicker.minuteInterval = 10
        ibDatePicker.minimumDate = Date()
    }
    
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


