//
//  RegisterViewController.swift
//  Hydrator
//
//  Created by Virgil Martinez on 1/24/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - OUTLETS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypePWField: UITextField!
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - ACTIONS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBAction func registerPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        
        if let email = emailField.text, !email.isEmpty { //email not empty
            if checkPassword() {
                if passwordField.text!.count < 6 {
                    SVProgressHUD.setMinimumDismissTimeInterval(1)
                    SVProgressHUD.showError(withStatus: "Password must be 6 or more characters.")
                    return
                }
                Auth.auth().createUser(withEmail: email, password: passwordField.text!, completion: { (user, error) in
                    if error != nil {
                        //Firebase error
                        SVProgressHUD.setMinimumDismissTimeInterval(1)
                        SVProgressHUD.showError(withStatus: "Error logging in")
                    }
                    //success
                    SVProgressHUD.dismiss(withDelay: 1)
                    SVProgressHUD.showSuccess(withStatus: "Registered Succesfully")
                    self.performSegue(withIdentifier: "toLog", sender: self)
                })
            }
        } else {
            //email empty
            SVProgressHUD.setMinimumDismissTimeInterval(1)
            SVProgressHUD.showError(withStatus: "No email")
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindtoViewController1", sender: self)
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Personal
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    func checkPassword() -> Bool {
        var matched = false
        
        //Checking passwords aren't empty and they match
        if !passwordField.text!.isEmpty && !retypePWField.text!.isEmpty {
            if passwordField.text! == retypePWField.text! {
                matched = true
                return matched
            } else {
                SVProgressHUD.setMinimumDismissTimeInterval(1)
                SVProgressHUD.showError(withStatus: "Passwords do not match")
                return matched
            }
        }else {
            SVProgressHUD.setMinimumDismissTimeInterval(1)
            SVProgressHUD.showError(withStatus: "Empty Password(s)")
            return matched
        }
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - System
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    override func viewDidLoad() {
        super.viewDidLoad()

        //dismiss keyboard
        hideKeyboardWhenTappedAround()
        //Setting up textfields for traversal
        emailField.delegate = self
        passwordField.delegate = self
        retypePWField.delegate = self
        emailField.returnKeyType = UIReturnKeyType.next
        passwordField.returnKeyType = UIReturnKeyType.next
        retypePWField.returnKeyType = UIReturnKeyType.go
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Textfield delegate function for traversal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true;
        }
        return false
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
}
