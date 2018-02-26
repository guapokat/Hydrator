//
//  LogViewController.swift
//  Hydrator
//
//  Created by Virgil Martinez on 1/25/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import CircleProgressView
import SwiftDate
import UserNotifications

class HydrationLogTableCell: UITableViewCell {
    // MARK: OUTLETS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var numericalAmount: UILabel!
    @IBOutlet weak var hydrationCellImg: UIImageView!
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
}

class LogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - OUTLETS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBOutlet weak var progressCircle: CircleProgressView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var hydrationTable: UITableView!
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - CONSTANTS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    let authenticate = Auth.auth()
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - VARIABLES
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    var total = 0.00
    var user: hydrationUser!
    var items: [HydrationLog] = []
    let notification = UNMutableNotificationContent()
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - System
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //table
        hydrationTable.delegate = self
        hydrationTable.dataSource = self
        
        //casting current user to user
        guard let user = authenticate.currentUser else {
            return
        }
        //configuring db path
        let currentUID = user.uid
        let ref = Database.database().reference(withPath: "\(currentUID)/HydrationLogs")
        
        //checking for user authentication
        authenticate.addStateDidChangeListener() { auth, user in
            guard let user = user else { //no user
                self.user = nil
                self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
                return
            }
            self.user = hydrationUser(authData: user)
        }
        
        //populating table
        ref.queryOrdered(byChild: "timeStamp").observe(.value, with: { snapshot in
            var newItems: [HydrationLog] = []
            //print(snapshot)
            for item in snapshot.children.allObjects {
                let hydrationLog = HydrationLog(snapshot: item as! DataSnapshot)
                newItems.append(hydrationLog)
            }
            self.items = newItems
            //checking for 24 hour persistence
            //This keeps the old data in the DB in order to be able to implement hydration Diaries (possible purchase option for future)
            self.items = self.twentyFourHours(logs: self.items)
            //animating table
            let range = NSMakeRange(0, self.hydrationTable.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.hydrationTable.reloadSections(sections as IndexSet, with: .automatic)
            //updating header
            self.updateTotal()
        })
        self.notificationGo(total: total)
        hydrationTable.allowsSelectionDuringEditing = false
        notification.sound = UNNotificationSound.default()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - ACTIONS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    //add is tied to a segue - this is for potential future use
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toAddVC", sender: self)
    }

    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            //troubleshooting
            print("Current user is: \(String(describing: authenticate.currentUser?.email))")
            try authenticate.signOut()
            SVProgressHUD.show(withStatus: "Logging Out")
            SVProgressHUD.dismiss(withDelay: 1)
            //troubleshooting should be nil
            print("Current user is: \(String(describing: authenticate.currentUser?.email))")
        } catch {
            SVProgressHUD.setMinimumDismissTimeInterval(1.25)
            SVProgressHUD.showError(withStatus: "Error Logging Out")
        }
        //user signed out so segue to loginVC
        self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - Personal
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    func updateTotal() {
        //updates total progress circle and label
        var totalWater = 0.0
        for i in items {
            if i.type == "Water" {
                totalWater += Double(i.amount)
            }
        }
        total = totalWater
        let percentage = Double((total / 64) * 100)
        //troubleshooting
        print("Total is: ", total)
        print("Percentage is: ", percentage)
        //casting to Int for label
        let prettyTotal = Int(total)
        //if user reached hydration goal
        if total >= 64 {
            self.progressCircle.setProgress(100, animated: true)
            totalLabel.text = String(64)
        } else {
            totalLabel.text = String(prettyTotal)
            self.progressCircle.setProgress((percentage / 100), animated: true)
        }
        notificationGo(total: total)
    }
    //Removes logs that are older than 24 hours but leaves old data in db for possible future use
    func twentyFourHours(logs: [HydrationLog]) -> [HydrationLog] {
        //empty arrays
        var tempLogs = logs
        var tempStrings: [String] = []
        //current date
        let now = Date()
        //empty string
        var tempString = ""
        //compare this ("yyyymd")
        let tempStamp = "\(now.year)\(now.month)\(now.day)"
        //index that is going to be cut at
        let indexToCut = tempStamp.count
        
        //fills tempStrings[] with String timestamps from current DB
        for i in 0..<logs.count {
            //filling tempStrings
            tempStrings.append(logs[i].timeStamp)
            print(tempStrings[i])
        }
        //cuts each String on tempStrings to the desired index (length of current tempStamp)
        for i in 0..<tempStrings.count {
            tempString = tempStrings[i]
            tempString = String(tempString[..<tempString.index(tempString.startIndex, offsetBy: indexToCut)])
            tempStrings[i] = tempString
        }
        //now tempStrings has a list of stamps at length tempStamp.count...time to compare and remove
        
        //reversing to avoid out of bounds error
        print("\nnow removing older than 24 hour data!\n")
        for i in (0..<logs.count).reversed() {
            if tempStrings[i] != tempStamp {
                tempLogs.remove(at: i)
            }
        }
        //troubleshooting
        for log in tempLogs {
            print("\(log.type) at time: \(log.timeStamp)")
        }
        return tempLogs
    }
    //Setting up notifications for reminders to hydrate
    func notificationGo(total: Double) {
        let remainder = 64 - total
        //if hydration is achieved don't remind
        if remainder <= 0.0 {
            return
        } else {
            if total == 0.0 {
                notification.body = "Lets get a start on your hydration!"
            } else if total <= 24.0 && total > 0.0 {
                notification.body = "Awesome start, keep it up!"
            } else if total <= 31.0 && total > 24.0 {
                notification.body  = "Almost halfway, keep going!"
            } else if total <= 48.0 && total > 31.0 {
                notification.body = "You are over halfway, lets finish!"
            } else if total <= 63.0 && total > 48.0 {
                notification.body = "Great job! you only have \(Int(remainder)) ounces left to reach 64!"
            }
            //get current time
            var time1 = DateComponents()
            var time2 = DateComponents()
            var time3 = DateComponents()
            var time4 = DateComponents()
            var time5 = DateComponents()
            var time6 = DateComponents()
            time1.hour = 9
            time2.hour = 11
            time3.hour = 13
            time4.hour = 15
            time5.hour = 17
            time6.hour = 20
            
            //only remind between 0900-2100 on a 2 hour basis
            let triggerOne = UNCalendarNotificationTrigger(dateMatching: time1, repeats: true)
            let triggerTwo = UNCalendarNotificationTrigger(dateMatching: time2, repeats: true)
            let triggerThree = UNCalendarNotificationTrigger(dateMatching: time3, repeats: true)
            let triggerFour = UNCalendarNotificationTrigger(dateMatching: time4, repeats: true)
            let triggerFive = UNCalendarNotificationTrigger(dateMatching: time5, repeats: true)
            let triggerSix = UNCalendarNotificationTrigger(dateMatching: time6, repeats: true)
            let hydrationReminder = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerOne)
            let hydrationReminder1 = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerTwo)
            let hydrationReminder2 = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerThree)
            let hydrationReminder3 = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerFour)
            let hydrationReminder4 = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerFive)
            let hydrationReminder5 = UNNotificationRequest(identifier: "notification1", content: notification, trigger: triggerSix)
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(hydrationReminder, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(hydrationReminder1, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(hydrationReminder2, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(hydrationReminder3, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(hydrationReminder4, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(hydrationReminder5, withCompletionHandler: nil)
        }
    }
    func checkTotal() {
        
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - TableView
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    //table size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //setting up each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "hydrationLog", for: indexPath) as! HydrationLogTableCell
        let hydrationItem = items[indexPath.row]
        cell.typeLabel.text = hydrationItem.type
        cell.hydrationCellImg.image = UIImage(named: "\(hydrationItem.type.lowercased())")
        cell.numericalAmount.text = String(hydrationItem.amount)
        return cell
    }
    //Allowing Delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hydrationLog = items[indexPath.row]
            hydrationLog.ref?.removeValue()
            updateTotal()
        }
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
}
