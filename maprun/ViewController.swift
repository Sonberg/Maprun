//
//  ViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Fakery
import Firebase
import FontAwesome_swift
import ChameleonFramework

protocol MissionDelegate {
    func didUpdateMission(mission : Mission)
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Varables
    var selectedIndexPath: IndexPath?
    let faker = Faker(locale: "sv")
    var user : User = User()
    var missions : [Mission] = [] {
        didSet {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    var editingMissions : Bool = false
    var missionDelegate : MissionDelegate?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK : - Fetch User
        self.returnUserRef { (user : User) in
            if user.id.characters.count > 0 {
                self.user = user
            }
        }
        
        
        self.firebase()
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        icon.image = #imageLiteral(resourceName: "icon-small")
        icon.contentMode = .scaleAspectFit
        self.navigationItem.titleView = icon
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.groupTableViewBackground
        view.backgroundColor = UIColor.groupTableViewBackground
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.setRightBarButtonItems([addButton(), editButton()], animated: true)
    }
    
    // MARK : - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.editingMissions {
            return self.missions.count
        }
        
        return missions.filter({ (mission : Mission) -> Bool in
            return mission.name.characters.count > 0
        }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
        cell.mission = missionAt(indexPath)
        cell.editingMissions = self.editingMissions
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = UIStoryboard(name: "Mission", bundle: nil).instantiateViewController(withIdentifier: "MapController") as! MapViewController
        
        selectedIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        controller.mission = missionAt(indexPath)
        controller.user = self.user
        missionDelegate = controller
        present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return !editingMissions
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Ta bort") { (action : UITableViewRowAction, indexPath : IndexPath) in
            self.missions.remove(at: indexPath.row)
        }
        
        return [delete]
    }
    
    // MARK : - Navigation
    
    
    
    // MARK : - Seed
    func seed() -> Mission {
        let mission = Mission()
        mission.name = faker.commerce.productName()
        mission.text = faker.address.country()
        
        while mission.questions.count < 5 {
            let question = Question()
            question.id = question.randomString(6)
            question.name = faker.commerce.productName()
            question.lat = faker.address.latitude()
            question.long = faker.address.longitude()
            mission.questions.append(question)
        }
        
        return mission
    }
    
    // MARK : - Helper
    func missionAt(_ indexPath : IndexPath) -> Mission {
        if self.editingMissions {
             return self.missions[indexPath.row]
        }
        return self.missions.filter({ (mission : Mission) -> Bool in
            return mission.name.characters.count > 0
        })[indexPath.row]
    }

}

// MARK: ExpandingTransitionPresentingViewController
extension ViewController: ExpandingTransitionPresentingViewController
{
    func expandingTransitionTargetViewForTransition(_ transition: ExpandingCellTransition) -> UIView! {
        if let indexPath = selectedIndexPath {
            return tableView.cellForRow(at: indexPath)
        } else {
            return nil
        }
    }
}

// MARK : - Firebase
extension ViewController {
    func firebase() {
        let ref = FIRDatabase.database().reference().child("schools").child("-KSg962QIiZbOxpG5lvg").child("missions")
        
        // MARK : - Add
        ref.queryOrderedByKey().observe(.childAdded) { (snap : FIRDataSnapshot) in
            self.missions.append(Mission(snap : snap))
        }
        
        // MARK : - Edit
        ref.queryOrderedByKey().observe(.childChanged) { (snap : FIRDataSnapshot) in
            for index in 0...self.missions.count - 1 {
                if self.missions[index].id == snap.key {
                    self.missions[index] = Mission(snap: snap)
                    self.missionDelegate?.didUpdateMission(mission: self.missions[index])
                }
            }
        }
        
        // MARK : - Delete
        ref.queryOrderedByKey().observe(.childRemoved) { (snap : FIRDataSnapshot) in
            for index in 0...self.missions.count - 1 {
                if self.missions[index].id == snap.key {
                    self.missions.remove(at: index)
                }
            }

        }
    }
}




// MARK : - Handle Buttons
extension ViewController {
    
    // MARK : - Create
    func addButton() -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ViewController.didTouchAdd(_:)), for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    func editButton() -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        button.setTitle("Redigera", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ViewController.didTouchEdit(_:)), for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    func cancelButton() -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        button.setTitle("Återställ ändringar", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ViewController.didTouchCancel(_:)), for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    func saveButton() -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Spara", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: (button.titleLabel?.font.pointSize)!)
        button.addTarget(self, action: #selector(ViewController.didTouchSave(_:)), for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    // MARK : - Actions

    func didTouchAdd(_ sender: Any) {
        editingMissions = true
        self.missions.append(Mission())
        self.navigationItem.setRightBarButtonItems([addButton(), cancelButton(), saveButton()], animated: false)
    }
    
    func didTouchEdit(_ sender: Any) {
        editingMissions = !editingMissions
        tableView.reloadData()
        self.navigationItem.setRightBarButtonItems([addButton(), cancelButton(), saveButton()], animated: false)
    }
    
    func didTouchSave(_ sender: Any) {
        editingMissions = false
        for cell in self.tableView.visibleCells {
            if cell is CardTableViewCell {
                let current : CardTableViewCell = cell as! CardTableViewCell
                let mission = current.export()
                if mission.name.characters.count > 0 {
                    mission.save(schoolId: "-KSg962QIiZbOxpG5lvg")
                }
            }
        }
        
        tableView.reloadData()
        self.navigationItem.setRightBarButtonItems([addButton(), editButton()], animated: false)
    }
    
    func didTouchCancel(_ sender: Any) {
        editingMissions = false
        tableView.reloadData()
        self.navigationItem.setRightBarButtonItems([addButton(), editButton()], animated: false)
    }
}

