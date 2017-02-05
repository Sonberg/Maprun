//
//  School.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-01.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase

class School: UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        super.init(snap: snap)
        
        let data : NSDictionary = snap.value as! NSDictionary
        
        if data["name"] != nil  {
            self.name = data["name"] as! String
        }
        
    }
    
    var name : String = ""
    var missions : [Mission] = []
}
