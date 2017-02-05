//
//  SidebarViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Spring
import SideMenu
import CZPicker
import Firebase
import ChameleonFramework
import FontAwesome_swift

protocol QuestionDelegate {
    func didSetMission(mission : Mission)
    func didUpdateQuestion(question : Question)
}

class SidebarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionDelegate, MissionDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Variables
    let screen = UIScreen.main.bounds
    var missionDelegate : MissionDelegate?
    var sidebarDelegate : SidebarDelegate?
    var user : User = User()
    var users : [User] = []
    var mission : Mission = Mission() {
        didSet {
            if self.mission.questions.count > 0 {
                
                // MARK : - Move progress
                if mission.id.characters.count > 0 {
                    for q in 0...mission.questions.count - 1 {
                        if oldValue.questions.count > 0 {
                            for o in 0...oldValue.questions.count - 1 {
                                if mission.questions[q].id == oldValue.questions[o].id  {
                                    
                                    // MARK : - Locked
                                    mission.questions[q].isLocked = oldValue.questions[o].isLocked
                                    
                                    
                                    
                                    // MARK : - Type progress
                                    if mission.questions[q].type == .choose {
                                        for a in 0...mission.questions[q].answers.count - 1 {
                                            for oa in 0...oldValue.questions[o].answers.count - 1 {
                                                if mission.questions[q].answers[a].id == oldValue.questions[o].answers[oa].id {
                                                    mission.questions[q].answers[a].isSelected = oldValue.questions[o].answers[oa].isSelected
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    if mission.questions[q].type == .image {
                                        mission.questions[q].image = oldValue.questions[o].image
                                        
                                    }
                                    
                                    if mission.questions[q].type == .text {
                                        mission.questions[q].answer = oldValue.questions[o].answer
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
    var editButton : UIButton?
    
    // MARK : - Actions
    func didTouchSubmit(_ sender : Any) {
        dismiss(animated: true) { 
            self.sidebarDelegate?.didSubmitMission(self.isMissionCompleted(), mission : self.mission)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = ""
        self.navigationController?.hidesNavigationBarHairline = true
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        footerViewForTableView()
        self.hideSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let parent = self.parent as! UISideMenuNavigationController
        if parent.isBeingDismissed {
            self.sidebarDelegate?.didCloseSidebar(mission: self.mission)
        }
    }

    
    
    // MARK : - Table View
    func didTouchEdit(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            self.editButton?.setTitle("Redigera", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            self.editButton?.setTitle("Klar", for: .normal)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        if section == 1 {
            return mission.questions.count + 1
        }
        
        if section == 2 {
            return 1
        }
        
        if section == 3 {
            return 2
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK : - Section 1
        if indexPath.section == 0 {
            
            // MARK : - Title
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
                cell.textLabel?.text = mission.name
                return cell
            }
            
            
            // MARK : - Text
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath)
                cell.textLabel?.text = mission.text
                return cell
            }
        }
        
        // MARK : - Section 2        
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                self.editButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
                self.editButton?.addTarget(self, action: #selector(SidebarViewController.didTouchEdit(_:)), for: .touchUpInside)
                self.editButton?.setImage(UIImage.fontAwesomeIcon(.edit, textColor: .darkGray, size: CGSize(width: 28, height: 28)), for: .normal)
                cell.textLabel?.text = "Frågor"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
                cell.accessoryView = self.editButton!

                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as! QuestionTableViewCell
            cell.question = questionAt(indexPath, offset: 1)
            return cell
            
        }
        
        // MARK : - Section 3
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Skapa ny fråga"
            cell.textLabel?.font = UIFont(name: "Futura", size: (cell.textLabel?.font.pointSize)!)
            cell.accessoryView = UIImageView(image: UIImage.fontAwesomeIcon(.plus, textColor: .darkGray, size: CGSize(width: 28, height: 28)))
            return cell
        }
        
        if indexPath.section == 3 {
            
            if indexPath.row == 1 {
                let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "subtitle")
                cell.textLabel?.text = "Studenter"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
                
                if self.mission.users.count > 1 {
                    cell.detailTextLabel?.text = String(self.mission.users.count) + " valda"
                } else {
                    cell.detailTextLabel?.text = String(self.mission.users.count) + " vald"
                }
                
                cell.accessoryView = UIImageView(image: UIImage.fontAwesomeIcon(.edit, textColor: .darkGray, size: CGSize(width: 28, height: 28)))
                return cell
            }
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        if indexPath.section == 1 && indexPath.row > 0 {
            if questionAt(indexPath, offset: 1).isLocked {
                return true
            }
        }
        
        if indexPath.section == 2 {
            return true
        }
        
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            didTouchEdit(indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            performSegue(withIdentifier: "editSegue", sender: self)
        }
        
        if indexPath.section == 1 && indexPath.row > 0 {
            performSegue(withIdentifier: "questionSegue", sender: self)
        }
        
        if indexPath.section == 3 {
            if indexPath.row == 1 {
               performSegue(withIdentifier: "usersSegue", sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row > 0 {
            return true
        }
        
        return false

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 && indexPath.row > 0 {
            let edit = UITableViewRowAction(style: .normal, title: "Redigera") { (action : UITableViewRowAction, indexPath : IndexPath) in
                self.editedIndexPath = indexPath
                self.performSegue(withIdentifier: "editSegue", sender: self)
                self.tableView.setEditing(false, animated: true)
            }
            
            return [edit]
        }
        return []
    }

    
    func footerViewForTableView() {
        let submitButton = SpringButton(frame: CGRect(x: 0, y: screen.size.height - 60, width: tableView.bounds.size.width, height: 60))
        submitButton.setTitle("Avbryt uppdrag", for: .normal)
        submitButton.backgroundColor = .flatYellow
        
        if isMissionCompleted() && self.mission.questions.count > 0 {
            submitButton.setTitle("Skicka in!", for: .normal)
            submitButton.backgroundColor = .flatGreen
        }
        
        
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.addTarget(self, action: #selector(SidebarViewController.didTouchSubmit(_:)), for: .touchUpInside)
        submitButton.animation = "fadeIn"
        view.addSubview(submitButton)
        submitButton.animate()
    }
    
    // MARK : - Question Delegate
    func didUpdateQuestion(question: Question) {
        if let index = self.mission.questions.index(where: { (oldValue : Question) -> Bool in
            if question.id == oldValue.id {
                return true
            }
            
            return false
        }) {
            self.mission.questions[index] = question
        } else {
            self.mission.questions.append(question)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK : - Did recive update from subview
    func didSetMission(mission: Mission) {
        self.mission = mission
        self.missionDelegate?.didUpdateMission(mission: mission)
    }
    
    // MARK : - Mission Delegate - From parent view
    func didUpdateMission(mission: Mission) {
        self.mission = mission
        self.missionDelegate?.didUpdateMission(mission: mission)
    }
   
    
    // MARK: - Navigation

    var editedIndexPath : IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // MARK : - Edit
        if segue.destination is EditQuestionViewController {
            let vc = segue.destination as! EditQuestionViewController
            vc.sidebarDelegate = self.sidebarDelegate
            vc.mission = self.mission
            vc.questionDelegate = self
            
            missionDelegate = vc
            
            
            if let indexPath : IndexPath = self.tableView.indexPathForSelectedRow {
                if indexPath.section == 2 && indexPath.row == 0 {
                    vc.question = Question(())
                } else {
                    vc.question = questionAt(indexPath, offset: 1)
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            if let indexPath : IndexPath  = editedIndexPath {
                vc.question = questionAt(indexPath, offset: 1)
                editedIndexPath = nil
            }
        }
        
        if segue.destination is QuestionViewController {
            let vc = segue.destination as! QuestionViewController
            vc.mission = self.mission
            vc.questionDelegate = self
            
            missionDelegate = vc
            
            if let indexPath : IndexPath = self.tableView.indexPathForSelectedRow {
                
                vc.question = questionAt(indexPath, offset: 1)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if segue.destination is QuestionViewController {
            let vc = segue.destination as! UsersTableViewController
            vc.mission = self.mission
            vc.user = self.user
        }
    }

    
    // MARK : - Helper
    func questionAt(_ indexPath : IndexPath, offset : Int = 0) -> Question {
        return self.mission.questions[indexPath.row - offset]
    }
    
    func isMissionCompleted() -> Bool {
        for question in self.mission.questions {
            if question.type == .choose {
                var answered : Bool = false
                for answer in question.answers {
                    if answer.isSelected {
                        answered = true
                    }
                }
                
                if !answered {
                    return false
                }
            }
            
            if question.type == .image {
                if question.image == nil {
                    return false
                }
            }
            
            if question.type == .text {
                if question.answer.characters.count == 0 {
                    return false
                }
            }
        }
        
        return true
    }
}

