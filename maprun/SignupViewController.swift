//
//  SignupViewController.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-27.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RKDropdownAlert
import CZPicker
import SVProgressHUD


class SignupViewController: UIViewController, CZPickerViewDelegate, CZPickerViewDataSource{
   
    var picker : CZPickerView?
    
    // MARK : - Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    // MARK : - Actions
    @IBAction func didTouchCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func didTouchSignup(_ sender: AnyObject) {
        self.picker?.show()
    }
    
    // MARK : - Variables
    var schools : [School] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fetchSchools()
        signUpBtn.layer.cornerRadius = 5
        
        self.view.backgroundColor = .flatYellow
        
        self.picker = CZPickerView(headerTitle: "Vilken skola går du på?", cancelButtonTitle: "Avbryt", confirmButtonTitle: "Godkänn")
        self.picker?.delegate = self
        self.picker?.dataSource = self
        
        self.picker?.checkmarkColor = .flatYellowDark
        self.picker?.headerTitleColor = .black
        self.picker?.headerBackgroundColor = .flatYellow
        self.picker?.confirmButtonBackgroundColor = .flatGreen
        self.picker?.needFooterView = true

    }
    
    // MARK : - Picker View
    func fetchSchools() -> Void {
        let ref = FIRDatabase.database().reference().child("schools")
        ref.queryOrderedByKey().observe(.childAdded) { (snap : FIRDataSnapshot) in
            self.schools.append(School(snap: snap))
            if self.picker != nil{
                self.picker?.reloadData()
            }
        }
    }
    
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return self.schools[row].name
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return self.schools.count
       
    }

    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        let fname = self.firstName.text!
        let lname = self.lastName.text!
        let mail = self.email.text!
        let word = self.password.text!
        let schoolId = self.schools[row].id
        
        if fname.characters.count == 0 || lname.characters.count == 0 || mail.characters.count == 0 || word.characters.count == 0 || schoolId.characters.count == 0 {
            RKDropdownAlert.title("Du måste fylla i alla fälten", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else {
            FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if error == nil {
                    if let user = FIRAuth.auth()?.currentUser {
                        
                        // MARK : - Store data
                        for _ in user.providerData {
                            let blueprint : [String : Any] = [
                                "uid" : user.uid,
                                "type" : "user",
                                "firstName" : fname,
                                "lastName" : lname,
                                "email" : mail,
                                "schoolId" : schoolId,
                                "photoURL" : ""
                                ] as [String : Any]
                            FIRDatabase.database().reference().child("users").childByAutoId().setValue(blueprint)
                             self.performSegue(withIdentifier: "loginSegue", sender: self)
                             self.showSpinner()
                        }
                    }
                    
                } else {
                    print(error)
                    RKDropdownAlert.title("Ett fel inträffade", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
                }
            })
           
        }
    }
    
   
}

