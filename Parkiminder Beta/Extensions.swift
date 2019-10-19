//
//  Extensions.swift
//  Parkiminder Beta
//
//  Created by dading on 19/10/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    // check whether date is in the same wek with self
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    // check whether date is in the same month with self
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    // check whether date is in previous n month with self
    func isInPreviousMonths(date: Date, n: Int) -> Bool {
        var i = 0
        while i <= n {
            let prevMo = Calendar.current.date(byAdding: .month, value: i, to: self)
            if((prevMo?.isInSameMonth(date: date))!) {
                return true
            }
            i += 1
        }
        return false
    }
    // return randomize date in prevMos previous months
    func randomDatetimeFrom(prevMos: Int) -> Date {
        let lowerDate = Calendar.current.date(byAdding: .month, value: -1*prevMos, to: self)
        var dc = DateComponents()
        dc.year = Calendar.current.component(.year, from: lowerDate!)
        dc.month = Calendar.current.component(.month, from: lowerDate!)
        let firstDay = Calendar.current.date(from: dc)
        
        let randomInterval = Double.random(in: firstDay!.timeIntervalSince1970...self.timeIntervalSince1970)
        return Date(timeIntervalSince1970: randomInterval)
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

extension UIView {
    // adjust view appearance to circle
    func makeCircle() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    // adjust view appearance to rounded corner
    func makeSquircle() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
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
        }
    }
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
