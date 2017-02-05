//
//  QuestionTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import FontAwesome_swift

class QuestionTableViewCell: UITableViewCell {
    
    var question : Question = Question() {
        didSet {
            var icon : FontAwesome = .unlockAlt
            self.textLabel?.text = question.name
            
            if question.isLocked {
                icon = .lock
            }
            
            // MARK : - Validate progress
            if  question.type == .choose {
                if question.answers.count > 0 {
                    for answer in question.answers {
                        if answer.isSelected {
                            icon = .check
                        }
                    }
                }
            }
            
            if  question.type == .text {
                if question.answer.characters.count > 0 {
                   icon = .check
                }
            }
            
            if  question.type == .image {
                if question.image != nil {
                    icon = .check
                }
            }
            
            self.accessoryView = UIImageView(image: UIImage.fontAwesomeIcon(icon, textColor: .darkGray, size: CGSize(width: 28, height: 28)))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
    }
}
