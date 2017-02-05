//
//  UIModel.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-28.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import RKDropdownAlert

class UIModel {
    
    init() {}
    init(snap : FIRDataSnapshot) {

        self.id = snap.key
        
        let data : NSDictionary = snap.value as! NSDictionary
        
        if data["created"] != nil  {
            self.created = data["created"] as! String
        }
        
        if data["updated"] != nil  {
            self.updated = data["updated"] as! String
        }
    }
    
    var id : String = ""
    var created : String = ""
    var updated : String = ""
    
    func getImage(_ url : String, completion: @escaping (UIImage) -> Void)  {
        if url != "" {
            FIRStorage.storage().reference(forURL: url).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                if (data != nil) {
                    completion(UIImage(data: data!)!)
                }
            })
        }
    }
    
    func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    // MARK : Upload Image
    func uploadImage(image : UIImage, completion: @escaping (String) -> Void) {
        let data : Data = UIImageJPEGRepresentation(image, 0.8)!
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        let storage = FIRStorage.storage().reference().child("images").child(randomString(6)).put(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                completion(downloadURL)
            }
        }
    }


    // MARK : - Save to database
    func save(ref : FIRDatabaseReference, data : [String : Any]) {
        var model : [String : Any] = data
        
        // MARk : - Save the date
        if self.id.characters.count == 0 {
            self.created = String(describing: Date())
        }
        
        self.updated = String(describing: Date())
        
        model.updateValue(self.created, forKey: "created")
        model.updateValue(self.updated, forKey: "updated")
        
        // MARK : - Update & Save
        if self.id.characters.count > 0 {
            ref.updateChildValues(model)
        } else {
            ref.setValue(model)
        }
        
        // MARK : - Alert User
        RKDropdownAlert.title("Sparat!", backgroundColor: UIColor.flatGreen, textColor: UIColor.init(contrastingBlackOrWhiteColorOn: UIColor.flatGreen, isFlat: true), time: 5)
    }
    
    // MARK : - Delete
    func delete(ref : FIRDatabaseReference) {
        ref.removeValue()
    }
}
