//
//  NavigationViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    // MARK : - Variables

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesNavigationBarHairline = true
        self.navigationBar.barTintColor = UIColor.flatYellow
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

