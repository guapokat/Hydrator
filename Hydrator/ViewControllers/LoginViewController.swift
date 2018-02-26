//
//  ViewController.swift
//  Hydrator
//
//  Created by Virgil Martinez on 1/18/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import SVProgressHUD


class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    // MARK: - OUTLETS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton! //TODO: hide if no entry in fields
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    
    
    
    // MARK: - ACTIONS
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if checkFields() {
            SVProgressHUD.show(withStatus: "Logging in")
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    SVProgressHUD.dismiss(withDelay: 1)
                    SVProgressHUD.showError(withStatus: "Error logging in")
                    
                }else {
                    print("Succesfully logged in with custom email")
                }
            })
        }
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - GOOGLE
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    @IBAction func customGoogleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }

    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    
    // MARK: - FACEBOOK
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBAction func customFBLogin(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil { //error logging in
                print("FB Login failed:", err!)
                return
            }
            self.FBlogin()
        }
    }
    
    func FBlogin() {
        
        SVProgressHUD.show(withStatus: "Logging In")
        //Grabbing FB 'AccessToken'
        let accessToken = FBSDKAccessToken.current()
        //shadowing
        guard let accessTokenString = accessToken?.tokenString else { return }
        //casting credentials
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        //SIGN IN
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with FB User: ", error ?? "")
                return
            }
            print("Successfully logged in with fb user: ", user ?? "")
        })
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err!)
                return
            }
            print(result!)
        }
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    // MARK: - SYSTEM
    override func viewDidLoad() {
        super.viewDidLoad()
        //Google
        GIDSignIn.sharedInstance().uiDelegate = self
        //dismiss keyboard
        hideKeyboardWhenTappedAround()
        //Setting up textfields for traversal
        emailField.delegate = self
        passwordField.delegate = self
        emailField.returnKeyType = UIReturnKeyType.next
        passwordField.returnKeyType = UIReturnKeyType.go
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToLogFromLogin", sender: nil)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    // MARK: - PERSONAL
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    func checkFields() -> Bool {
        var g2g = false
        if let email = emailField.text, !email.isEmpty {
            if let password = passwordField.text, !password.isEmpty {
                g2g = true
            } else {
                SVProgressHUD.dismiss(withDelay: 1)
                SVProgressHUD.showError(withStatus: "No password")
            }
        } else {
            SVProgressHUD.dismiss(withDelay: 1)
            SVProgressHUD.showError(withStatus: "No email")
        }
        return g2g
    }
}
