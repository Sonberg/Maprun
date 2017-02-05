//
//  Mission.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import Firebase
import Foundation

class Mission : UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        super.init(snap: snap)
        
        let data : NSDictionary = snap.value as! NSDictionary
        
        if data["name"] != nil  {
            self.name = data["name"] as! String
        }
        
        if data["text"] != nil  {
            self.text = data["text"] as! String
        }
        
        
        if data["users"] != nil  {
            self.users = data["users"] as! [String]
        }

        
        // MARK : - Add Children
        if snap.hasChild("questions") {
            for child in snap.childSnapshot(forPath: "questions").children.allObjects as! [FIRDataSnapshot] {
                questions.append(Question(snap: child))
            }
        }
    }
    
    var name : String = ""
    var text : String = ""
    var users : [String] = []
    var questions : [Question] = []
    
    // MARK : - Save
    func save(schoolId : String) {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("schools").child(schoolId).child("missions").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("schools").child(schoolId).child("missions").childByAutoId()
        }
        
        let data : [String : Any] = [
            "name" : self.name,
            "text" : self.text
        ]
        
        super.save(ref: ref, data: data)
    }
}
