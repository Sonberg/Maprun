//
//  SeperatorTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-28.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class SeperatorTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
