//
//  NotificationSettingsViewController.swift
//  AccountBook
//
//  Created by yang on 3/15/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UIViewController {

    @IBOutlet weak var notificationTimeLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBAction func switchNotificationState(_ sender: UISwitch) {
        if sender.isOn {
            notificationTimeLabel.isHidden = false
            datePicker.isHidden = false
            let hour = Calendar.current.component(.hour, from: datePicker.date)
            let minute = Calendar.current.component(.minute, from: datePicker.date)
            addNotification(at: (hour, minute))
        }
        else {
            UserDefaults.standard.set(false, forKey: "Notification")
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["AccountBookLocalNotification"])
            notificationTimeLabel.isHidden = true
            datePicker.isHidden = true
        }
    }
    
    @IBAction func newNotificationTimeSet(_ sender: UIDatePicker) {
        let hour = Calendar.current.component(.hour, from: sender.date)
        let minute = Calendar.current.component(.minute, from: sender.date)
        addNotification(at: (hour, minute))
    }
    
    // MARK: View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Party LET", size: 30.0)!, NSForegroundColorAttributeName: UIColor.white]
        let notificationState = UserDefaults.standard.bool(forKey: "Notification")
        notificationSwitch.setOn(notificationState, animated: false)
        if !notificationState {
            notificationTimeLabel.isHidden = true
            datePicker.isHidden = true
        } else {
            let hour = UserDefaults.standard.integer(forKey: "NotificationTime-Hour")
            let minute = UserDefaults.standard.integer(forKey: "NotificationTime-Minute")
            if let date = getDateFromHourMinuteString(for: "\(hour):\(minute)") {
                datePicker.setDate(date, animated: true)
            }
            
        }
    }
}
