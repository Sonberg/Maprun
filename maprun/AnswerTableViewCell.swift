//
//  answerCell.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-22.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import M13Checkbox
import ChameleonFramework

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var label: UILabel!
    
    var answer : Answer = Answer() {
        didSet {
            self.checkbox.tintColor = .flatYellowDark
            self.label.text = answer.text
            
            // MARK : - Checkstate
            if answer.isSelected {
                self.checkbox.setCheckState(M13Checkbox.CheckState.checked, animated: true)
            } else {
                self.checkbox.setCheckState(M13Checkbox.CheckState.unchecked, animated: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = false
    }
    
    

}
