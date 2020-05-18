//
//  InfoController.swift
//  SolAR System

//
//  Created by Luciano Amoroso on 12/05/19.
//  Copyright © 2019 Luciano Amoroso. All rights reserved.
//

import Foundation
import UIKit

class InfoController: UIViewController{
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var Infolabel: UILabel!
    override func viewDidLoad() {
            super.viewDidLoad()
        
        //Image and Label for Info Screen
        Infolabel.text = infor
        Infolabel.numberOfLines = 0
        Infolabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        imageV.image = UIImage(named: "256")
        }
}
