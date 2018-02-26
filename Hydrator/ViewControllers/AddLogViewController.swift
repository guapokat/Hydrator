//
//  AddLogViewController.swift
//  Hydrator
//
//  Created by Virgil Martinez on 1/29/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftDate
import SVProgressHUD

class AddLogViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Outlets
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var amountTextfield: UITextField!
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Variables
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    var typeList = ["Water", "Coffee", "Soda", "Beer", "Wine", "Other"]
    //var typeList = ["Beer", "Coffee", "Other", "Soda", "", "Wine"]
    var amount = 6
    var selectedType: String = "Water"
    var selectedAmount: Int = 6
    var user: hydrationUser!
    var ref = Database.database().reference(withPath: "Lost Data")
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    
    //MARK: - Constants
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    //connceting to firebase
    let calendar = NSCalendar.current
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    //MARK: - System Functions
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //Connect picker view(s)
        typePickerView.delegate = self
        typePickerView.dataSource = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else { return }
            self.user = hydrationUser(authData: user)
            let currentUID = self.user.uid
            self.ref = Database.database().reference(withPath: "\(currentUID)/HydrationLogs")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Slider
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    let step: Float = 2
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        //amount = Int(amountSlider.value)
        amount = Int(roundedValue)
        selectedAmount = amount
        amountTextfield.text = String(amount)
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Picker View
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 75.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: typePickerView.bounds.width, height: 60))
        let imageView = UIImageView(frame: CGRect(x: 90, y: 0, width: typePickerView.bounds.width, height: 60))
        
        imageView.contentMode = .scaleAspectFit
        var rowString = String()
        switch row {
            //var typeList = ["Water", "Coffee", "Soda", "Beer", "Wine", "Other"]
            case 0:
                rowString = "Water"
                imageView.image = #imageLiteral(resourceName: "water")
            case 1:
                rowString = "Coffee"
                imageView.image = #imageLiteral(resourceName: "coffee")
            case 2:
                rowString = "Soda"
                imageView.image = #imageLiteral(resourceName: "soda")
            case 3:
                rowString = "Beer"
                imageView.image = #imageLiteral(resourceName: "beer")
            case 4:
                rowString = "Wine"
                imageView.image = #imageLiteral(resourceName: "wine")
            case 5:
                rowString = "Other"
                imageView.image = #imageLiteral(resourceName: "other")
        default:
            rowString = "Error: too many rows"
            imageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x: 60, y: 0, width: typePickerView.bounds.width - 90, height: 60))
        myLabel.text = rowString
        myLabel.textColor = UIColor.white
        myLabel.font = UIFont(name: "Dosis", size: 22.0)
        myView.addSubview(myLabel)
        myView.addSubview(imageView)
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = typeList[row]
        print("Type is \(selectedType)")
    }
    
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Personal Functions
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    func successAndBack(type: String, amount: Int) {
        SVProgressHUD.showSuccess(withStatus: "Added: \(amount)oz of '\(type)'")
        SVProgressHUD.dismiss(withDelay: 1)
        //self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Actions
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBAction func addButtonPressed(_ sender: UIButton) {
        //getting system's current date settings
        let currentDate = Date()
        //formatting to send to Firebase
        let dateKey = "\(currentDate.year)\(currentDate.month)\(currentDate.day)\(currentDate.hour)\(currentDate.minute)\(currentDate.second)\(currentDate.nanosecond)"
        //Creating a HydrationLog instance called 'logItem'
        let logItem = HydrationLog(type: selectedType, addedByUser: self.user.email, timeStamp: dateKey, amount: selectedAmount)
        //Creating a reference to that to send to Firebase
        let logItemRef = self.ref.child(logItem.timeStamp)
        //Setting value/Sending value to Firebase
        logItemRef.setValue(logItem.toAnyObject())
        //Showing success and sending back
        successAndBack(type: logItem.type, amount: logItem.amount)
    }
    
    
    //@IBAction func backPressed(_ sender: Any) {
      //  self.dismiss(animated: true, completion: nil)
    //}
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
}
