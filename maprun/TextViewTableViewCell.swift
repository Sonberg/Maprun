//
//  TextViewTableViewCell.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-28.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    // MARK : - Outlet
    @IBOutlet weak var textView: KMPlaceholderTextView!
    
    // MARK : - Variable
    var content : String = "" {
        didSet {
            textView.delegate = self
            textView.text = content
        }
    }
    
    // MARK : - Delegate
    func textViewDidEndEditing(_ textView: UITextView) {
        print("didstop exit")
        content = textView.text
    }
}
