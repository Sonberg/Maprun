//
//  DescTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-01.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class DescTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    var question : Question = Question() {
        didSet {
            self.label.text = question.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = false
    }
}
