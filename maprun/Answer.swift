//
//  Answer.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-28.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase

class Answer: UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        super.init(snap: snap)
        
        if let data : NSDictionary = snap.value as? NSDictionary {
        
            if data["isCorrect"] != nil  {
                self.isCorrect = data["isCorrect"] as! Bool
            }
            
            if data["text"] != nil  {
                self.text =  data["text"] as! String
            }
        
        }
    }
    
    var text : String = ""
    var isCorrect : Bool = false
    var isSelected : Bool = false
    
    func save(base : FIRDatabaseReference)  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = base.child("answers").child(self.id)
        } else {
            ref = base.child("answers").childByAutoId()
        }
        
        let data : [String : Any] = [
            "isCorrect" : self.isCorrect,
            "text" : self.text
        ]
        
        super.save(ref: ref, data: data)

    }
}
