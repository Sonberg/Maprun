//
//  CardTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import FontAwesome_swift
import ChameleonFramework

class CardTableViewCell: UITableViewCell {

    // MARK : - Outlet
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var descLabel: UITextField!
    
    var color : UIColor = UIColor.groupTableViewBackground
    var editingMissions : Bool = false {
        didSet {
            if editingMissions {
                titleLabel.borderStyle = .roundedRect
                titleLabel.isEnabled = true
                titleLabel.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.4)
                
                descLabel.borderStyle = .roundedRect
                descLabel.isEnabled = true
                descLabel.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.4)
            }
            
            if !editingMissions {
                titleLabel.borderStyle = .none
                titleLabel.isEnabled = false
                titleLabel.backgroundColor = .clear
                
                descLabel.borderStyle = .none
                descLabel.isEnabled = false
                descLabel.backgroundColor = .clear
            }
            
            if self.editingMissions {
                self.accessoryView = nil
            } else {
                self.accessoryView = UIImageView(image: UIImage.fontAwesomeIcon(.chevronRight, textColor: color.darken(byPercentage: 0.3)!, size: CGSize(width: 32, height: 32)))
            }
        }
    }
    
    var mission : Mission? {
        didSet {
            titleLabel.text = mission?.name
            titleLabel.textColor = color.darken(byPercentage: 0.75)
            descLabel.text = mission?.text
            
            let screen = UIScreen.main.bounds
            var width : CGFloat = screen.size.height
            
            if screen.size.height > screen.size.width {
                width = screen.size.height
            }
            
            let border = UIView(frame: CGRect(x: 0, y: self.contentView.frame.size.height - 8, width: width, height: 8))
            border.backgroundColor = color
            self.contentView.addSubview(border)
        }
    }
    
    func export() -> Mission {
        self.mission?.name = titleLabel.text!
        self.mission?.text = descLabel.text!
        return self.mission!
    }
}
