//
//  ImageTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-02-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import ChameleonFramework

class ImageTableViewCell: UITableViewCell {

    // MARK : - Outlet
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // MARK : - Variable
    var question : Question = Question() {
        didSet {
            if question.image == nil {
                userImage.alpha = 0
                label.textColor = .black
            } else {
                userImage.alpha = 1
                userImage.image = question.image
                
                label.textColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFrom: question.image!), isFlat: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = false
    }
    
}
