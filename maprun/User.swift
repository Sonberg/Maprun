//
//  user.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-28.
//  Copyright © 2016 persimon. All rights reserved.
//

import Firebase
import Foundation
import FirebaseAuth
import RKDropdownAlert

enum UserType {
    init(rawValue: String) {
        switch rawValue {
        case "admin":
            self = .admin
            break
            
        case "user":
            self = .user
            break
            
        default:
            self = .user
            break
        }
    }
    
    case admin
    case user
}


class User : UIModel {
    
    override init() {
        super.init()
    }
    
    override init(snap : FIRDataSnapshot) {
        
        super.init(snap: snap)
        
        let data : NSDictionary = snap.value as! NSDictionary
        self.id = snap.key
        
        if data["uid"] != nil  {
            self.uid =  data["uid"] as! String
        }
        
        if data["type"] != nil  {
            self.type = UserType(rawValue: data["type"] as! String)
        }
        
        if data["firstName"] != nil  {
            self.firstName = data["firstName"] as! String
        }
        
        if data["lastName"] != nil  {
            self.lastName =  data["lastName"] as! String
        }
        
        if data["email"] != nil  {
            self.email = data["email"] as! String
        }
        
        if data["url"] != nil  {
            self.url = data["url"] as! String
        }
        
        if data["schoolId"] != nil  {
            self.schoolId = data["schoolId"] as! String
        }
        
    }
    

    var uid : String = ""
    var url : String = ""
    var type : UserType = .user
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var schoolId : String = ""
    var image : UIImage? = nil
    
    
    func save()  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("users").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("users").childByAutoId()
        }
        
        let data : [String : Any] = [
            "uid" : self.uid,
            "url" : self.url,
            "type" : String(describing: self.type),
            "firstName" : self.firstName,
            "lastName" : self.lastName,
            "email" : self.email
        ]
        
        if self.id.characters.count > 0 {
            ref.updateChildValues(data)
        } else {
            ref.setValue(data)
        }
        
        if self.image != nil {
            print("Saving image...")
            let data : Data = UIImageJPEGRepresentation(self.image!, 0.8)!
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            _ = FIRStorage.storage().reference().child("users").child(self.id).child(super.randomString(6)).put(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    ref.child("url").setValue(downloadURL)
                }
            }
        }
        RKDropdownAlert.title("Sparat!", backgroundColor: UIColor.flatGreen, textColor: UIColor.init(contrastingBlackOrWhiteColorOn: UIColor.flatGreen, isFlat: true), time: 5)
        
    }

}
