//
//  UsersTableViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase
import DynamicButton

class UsersTableViewController: UITableViewController, MissionDelegate {

    // MARK : - Variables
    var questionDelegate : QuestionDelegate?
    var mission : Mission = Mission() {
        didSet {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    var user : User = User()
    var users : [User] = [] {
        didSet {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    func didTouchClose(_ sender : Any) {
        
        // MARK : - Get answer
       questionDelegate?.didSetMission(mission: self.mission)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(UsersTableViewController.didTouchClose(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
        
        self.clearsSelectionOnViewWillAppear = false
        self.getUsers()
        self.navigationItem.title = "Välj klasskamrater"
    }
    
    // MARK : - Mission Delegate
    func didUpdateMission(mission: Mission) {
        self.mission = mission
    }

    // MARK : - Firebase
    func getUsers() -> Void {
        let ref = FIRDatabase.database().reference().child("users")
        ref.queryOrderedByKey().observe(.childAdded) { (snap : FIRDataSnapshot) in
            let model = User(snap: snap)
            if model.id != self.user.id {
                if model.schoolId == self.user.schoolId {
                    self.users.append(model)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.tintColor = .flatYellowDark
        cell.selectionStyle = .none
        cell.textLabel?.text = user.firstName.capitalizingFirstLetter() + " " + user.lastName.capitalizingFirstLetter()
        
        if self.mission.users.contains(user.id) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if let index = self.mission.users.index(of: user.id) {
                self.mission.users.remove(at: index)
                cell.accessoryType = .none
            } else {
                self.mission.users.append(user.id)
                cell.accessoryType = .checkmark
            }
        }

    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
