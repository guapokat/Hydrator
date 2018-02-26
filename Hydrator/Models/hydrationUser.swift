//
//  User.swift
//  Hydrator
//
//  Created by Virgil Martinez on 2/2/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct hydrationUser {
    let uid: String
    let email: String
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
