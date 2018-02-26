//
//  AboutViewController.swift
//  Hydrator
//
//  Created by Virgil Martinez on 2/8/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    //MARK: - System
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //MARK: - Actions
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func instagramPressed(_ sender: Any) {
        if let url = NSURL(string: "https://www.instagram.com/virgilmartinez/"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
    @IBAction func twitterPressed(_ sender: Any) {
        if let url = NSURL(string: "https://twitter.com/guapokat"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
    @IBAction func linkedInPressed(_ sender: Any) {
        if let url = NSURL(string: "https://www.linkedin.com/in/virgil-martinez-226a2490"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
    @IBAction func gitHubPressed(_ sender: Any) {
        if let url = NSURL(string: "https://github.com/guapokat"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
}
