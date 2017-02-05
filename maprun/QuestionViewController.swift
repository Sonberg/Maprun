//
//  QuestionViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-01.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import M13Checkbox
import DynamicButton

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MissionDelegate {

    // MARK : - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Action
    @IBAction func tapSomething(_ sender: Any) {
        print("some tap")
    }
    func didTouchClose(_ sender : Any) {
        
        // MARK : - Get answer
        for cell in self.tableView.visibleCells {
            if let indexPath : IndexPath = self.tableView.indexPath(for: cell) {
                if indexPath.section == 1 {
                    
                    // MARK : - Text
                    if self.question.type == .text {
                        let current = cell as! TextViewTableViewCell
                        self.question.answer = current.textView.text

                    }
                    
                    // MARK : - Image
                    if self.question.type == .image {
                        let current = cell as! ImageTableViewCell
                        self.question.image = current.question.image
                    }
                    
                    // MARK : - Choose
                    if self.question.type == .choose {
                        let current = cell as! AnswerTableViewCell
                        self.question.answers[indexPath.row] = current.answer
                        
                        if current.checkbox.checkState == .checked {
                            self.question.answers[indexPath.row].isSelected = true
                        } else {
                            self.question.answers[indexPath.row].isSelected = false
                        }
                    }
                    
                }
            }
        }
        
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK : - Variable
    var questionDelegate : QuestionDelegate?
    var mission : Mission = Mission()
    var question : Question = Question() {
        didSet {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(QuestionViewController.didTouchClose(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsSelection = true
        self.tableView.bounces = true
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.questionDelegate?.didUpdateQuestion(question: self.question)
    }
    
    // MARK : - Mission Delegate
    func didUpdateMission(mission: Mission) {
        self.mission = mission
    }
    
    // MARK : - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // MARK : - Question info
        if section == 0 {
            return 2
        }
        
        // MARK : - Questions
        if self.question.type == .choose {
            return self.question.answers.count
        }
        
        // MARK : - For Media & Text
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {

            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as! TitleTableViewCell
                cell.question = self.question
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "desc", for: indexPath) as! DescTableViewCell
                cell.question = self.question
                return cell
            }
        }
        

        if self.question.type == .choose {
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as! AnswerTableViewCell
                cell.answer = self.question.answers[indexPath.row]
                cell.selectionStyle = .default
                return cell
            }
        }
        
        if self.question.type == .image {
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! ImageTableViewCell
                cell.question = question
                cell.selectionStyle = .default
                return cell
            }
        }
        
        if self.question.type == .text {
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextViewTableViewCell
                cell.content = question.answer
                cell.selectionStyle = .default
                return cell
            }
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            if indexPath.section == 1 {
                return true
            }
        return false

    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // MARK : - Choose
        if self.question.type == .choose {
            if indexPath.section == 1 {
                let cell = tableView.cellForRow(at: indexPath) as! AnswerTableViewCell
                cell.answer.isSelected = !cell.answer.isSelected
                if cell.answer.isSelected {
                    cell.checkbox.setCheckState(M13Checkbox.CheckState.checked, animated: true)
                } else {
                    cell.checkbox.setCheckState(M13Checkbox.CheckState.unchecked, animated: true)
                }
            }
        }
        
        // MARK : - Image
        if self.question.type == .image {
            if indexPath.section == 1 {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(picker, animated: true, completion: nil)
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && self.question.type != .choose {
            return 300.0
        }
        
        return UITableViewAutomaticDimension
    }
    
    // MARK : - Image Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        self.question.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
}
