//
//  DisplayController.swift
//  EinsteinVisionExample
//
//  Created by Renee Liu on 11/15/17.
//  Copyright © 2017 René Winkelmeyer. All rights reserved.
//

import Foundation
import UIKit

class DisplayController: UIViewController {

    var currCategory: String!
    
    @IBOutlet weak var headerText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.headerText.text = self.currCategory
        self.title = self.currCategory
        
    }
    


}
