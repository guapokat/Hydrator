//
//  HydrationLog.swift
//  Hydrator
//
//  Created by Virgil Martinez on 2/2/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftDate

struct HydrationLog {
    let key: String
    let type: String
    let addedByUser: String
    let amount: Int
    let timeStamp: String!
    let ref: DatabaseReference?
    
    
    init(type: String, addedByUser: String, timeStamp: String, amount: Int, key: String = "") {
        self.key = key
        self.type = type
        self.amount = amount
        self.addedByUser = addedByUser
        self.timeStamp = timeStamp
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        type = snapshotValue["type"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        amount = snapshotValue["amount"] as! Int
        timeStamp = snapshotValue["timeStamp"] as? String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "type": type,
            "addedByUser": addedByUser,
            "timeStamp" : timeStamp,
            "amount": amount
        ]
    }
}
