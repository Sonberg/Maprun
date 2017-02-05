//
//  TitleTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-01.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    var question : Question = Question() {
        didSet {
            self.label.text = question.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = false
    }
}
