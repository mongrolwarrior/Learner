//
//  InterfaceController.swift
//  watchLearner Extension
//
//  Created by Andrew Amos on 9/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var answerIsHidden = true
    var session: WCSession!
    
    @IBOutlet var showAnswerButton: WKInterfaceButton!
    @IBOutlet var questionLabel: WKInterfaceLabel!
    @IBOutlet var answerLabel: WKInterfaceLabel!
    @IBOutlet var questionImage: WKInterfaceImage!
    
    @IBAction func showAnswerButtonAction() {
        if answerIsHidden {
            showAnswerButton.setTitle("Show Question")
            answerLabel.setHidden(false)
            questionImage.setHidden(false)
        } else {
            showAnswerButton.setTitle("Show Answer")
            answerLabel.setHidden(true)
        }
        answerIsHidden = !answerIsHidden
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        let applicationData = ["counterValue": "value"]
        
        session.sendMessage(applicationData, replyHandler: {(reply: [String : AnyObject]) -> Void in
            if let question = reply["question"] as? String,
                let answer = reply["answer"] as? String,
                let qImage = reply["qImage"] as? String,
                let aImage = reply["aImage"] as? String
            {
                self.setDisplay(question, answer: answer, qImage: qImage, aImage: aImage)
            }
        }, errorHandler:
            {
                (error ) -> Void in
                // catch any errors here
            }
        )
    }
    
    func setDisplay(question: String, answer: String, qImage: String, aImage: String) {
        if !question.isEmpty {
            self.questionLabel.setText(question)
        }
        if !answer.isEmpty {
            self.answerLabel.setText(answer)
        }
        if !qImage.isEmpty {
            var qImageNew = qImage.stringByReplacingOccurrencesOfString(".svg", withString: "")
            qImageNew = qImageNew.stringByReplacingOccurrencesOfString(".gif", withString: "")
            questionImage.setImageNamed(qImageNew)
            questionImage.setHidden(false)
        }
        if !aImage.isEmpty {
            print("load answer image")
            questionImage.setHidden(true)
        }
        self.answerLabel.setHidden(true)
        answerIsHidden = true
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
