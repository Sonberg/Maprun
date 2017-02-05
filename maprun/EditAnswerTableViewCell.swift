//
//  editAnwerCell.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-25.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import M13Checkbox

class EditAnswerTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var textEdit: UITextField!
    
    var answer : Answer = Answer() {
        didSet {
            checkbox.addTarget(self, action: #selector(EditAnswerTableViewCell.didChangeCheckbox(_:)), for: .touchUpInside)
            textEdit.text = answer.text
            textEdit.delegate = self
            if answer.isCorrect {
                checkbox.setCheckState(M13Checkbox.CheckState.checked, animated: true)
            } else {
                checkbox.setCheckState(M13Checkbox.CheckState.unchecked, animated: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
         checkbox.addTarget(self, action: #selector(EditAnswerTableViewCell.didChangeCheckbox(_:)), for: .touchUpInside)
    }
    
    func didChangeCheckbox(_ sender : Any) {
        if checkbox.checkState == .checked {
            answer.isCorrect = true
        } else {
            answer.isCorrect = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            answer.text = text
        }
    }
}
