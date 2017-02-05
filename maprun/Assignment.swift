//
//  Assignment.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-01.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase

class Assignment: UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        super.init(snap: snap)

        let data : NSDictionary = snap.value as! NSDictionary

        if data["completed"] != nil  {
            self.completed = data["completed"] as! Bool
        }
        
        if data["user"] != nil  {
            self.user =  data["user"] as! String
        }
        
        if data["mission"] != nil  {
            self.mission = data["mission"] as! String
        }
        
        if data["assignedBy"] != nil  {
            self.assignedBy = data["assignedBy"] as! String
        }
        
    }
    
    var completed : Bool = false
    var user : String = ""
    var mission : String = ""
    var assignedBy : String = ""
}
