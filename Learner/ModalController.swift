//
//  ModalController.swift
//  Learner
//
//  Created by Andrew Amos on 13/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import UIKit

class ModalController: UIViewController {
    var answerText = String()
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !answerText.isEmpty {
            answerLabel.text = answerText
        } else {
            answerLabel.text = "No answer provided"
        }
    }
    
}