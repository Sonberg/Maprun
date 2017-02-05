//
//  Mission.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import MapKit
import Firebase
import Foundation

enum questionType : String {
    case text = "text"
    case choose = "choose"
    case image = "image"
}

class Question : UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        super.init(snap: snap)
        
        self.id = snap.key
        
        let data : NSDictionary = snap.value as! NSDictionary
        
        
        if data["name"] != nil  {
            self.name = data["name"] as! String
        }
        
        if data["text"] != nil  {
            self.text =  data["text"] as! String
        }
        
        if data["type"] != nil  {
            self.type = questionType(rawValue: data["type"] as! String)!
        }

        
        if data["url"] != nil  {
            self.url = data["url"] as! String
        }
        
        if data["lat"] != nil  {
            self.lat = data["lat"] as! Double
        }
        
        if data["long"] != nil  {
            self.long = data["long"] as! Double
        }
        
        self.isNew = false
        
        // MARK : - Add Children
        if snap.hasChild("answers") {
            for child in snap.childSnapshot(forPath: "answers").children.allObjects as! [FIRDataSnapshot] {
                self.answers.append(Answer(snap: child))
            }
        }

    }
    
    var name : String = ""
    var text : String = ""
    var url : String = ""
    var lat : Double = 0
    var long : Double = 0
    var type : questionType = .text
    
    var isNew : Bool = true
    var isLocked : Bool = true
    var isAnswered: Bool = false
    var answers : [Answer] = []
    var answer : String = ""
    var image : UIImage?
    var annotation : MKPointAnnotation?
    
    
    func save(_ schoolId: String, missionId : String) {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("schools").child(schoolId).child("missions").child(missionId).child("questions").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("schools").child(schoolId).child("missions").child(missionId).child("questions").childByAutoId()
        }
        
        let data : [String : Any] = [
            "name" : self.name,
            "text" : self.text,
            "url" : self.url,
            "lat" : self.lat,
            "long" : self.long,
            "type" : String(describing: self.type)
        ]
        
        super.save(ref: ref, data: data)
        
        // MARK : - Save answers
        if self.type == .choose {
            for answer in self.answers {
                answer.save(base: ref)
            }
        }
    }
    
    func delete(_ schoolId: String, missionId : String) {
        FIRDatabase.database().reference().child("schools").child(schoolId).child("missions").child(missionId).child(self.id).removeValue()
    }
}
