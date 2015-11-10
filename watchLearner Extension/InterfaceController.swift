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
    var currentQid: NSNumber?
    
    @IBOutlet var showAnswerButton: WKInterfaceButton!
    @IBOutlet var questionLabel: WKInterfaceLabel!
    @IBOutlet var answerLabel: WKInterfaceLabel!
    @IBOutlet var questionImage: WKInterfaceImage!
    
    @IBOutlet var nextDueDate: WKInterfaceLabel!
    @IBOutlet var nextDueTimer: WKInterfaceTimer!
    
    func sendAnswerToiPhone(accuracy: Bool) {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        var answerData: [String: AnyObject] = ["messageType": "sendAnswer"]
        answerData["accuracy"] = accuracy
        
        if self.currentQid != nil {
            answerData["qid"] = currentQid
        }

        session.sendMessage(answerData, replyHandler: {(reply: [String : AnyObject]) -> Void in
            if let nextDue = reply["nextdue"] as? String
            {
                self.setNextDueDisplay(nextDue)
            }
            }, errorHandler:
            {
                (error ) -> Void in
                // catch any errors here
            }
        )
        getQuestionFromiPhone()
    }
    
    @IBAction func onCorrectAnswer() {
        sendAnswerToiPhone(true)
    }
    
    @IBAction func onIncorrectAnswer() {
        sendAnswerToiPhone(false)
    }
    
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

    func getQuestionFromiPhone() {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        let applicationData = ["messageType": "getQuestion"]
        
        session.sendMessage(applicationData, replyHandler: {(reply: [String : AnyObject]) -> Void in
            if let question = reply["question"] as? String,
                let answer = reply["answer"] as? String,
                let qImage = reply["qImage"] as? String,
                let aImage = reply["aImage"] as? String,
                let qid = reply["qid"] as? NSNumber
            {
                self.setDisplay(question, answer: answer, qImage: qImage, aImage: aImage)
                self.currentQid = qid
            }
            }, errorHandler:
            {
                (error ) -> Void in
                // catch any errors here
            }
        )
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.getQuestionFromiPhone()
    }
    
    func setDisplay(question: String, answer: String, qImage: String, aImage: String) {
        questionImage.setImage(nil)
        questionImage.setHidden(true)
        if !question.isEmpty {
            self.questionLabel.setHidden(false)
            self.questionLabel.setText(question)
        } else {
            self.questionLabel.setHidden(true)
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
            var aImageNew = aImage.stringByReplacingOccurrencesOfString(".svg", withString: "")
            aImageNew = aImageNew.stringByReplacingOccurrencesOfString(".gif", withString: "")
            questionImage.setImageNamed(aImageNew)
            questionImage.setHidden(true)
        }
        self.answerLabel.setHidden(true)
        answerIsHidden = true
    }
    
    func setNextDueDisplay(nextDue: String) {
        self.nextDueDate.setHidden(false)
        self.nextDueDate.setText(nextDue)
        /*
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
            var aImageNew = aImage.stringByReplacingOccurrencesOfString(".svg", withString: "")
            aImageNew = aImageNew.stringByReplacingOccurrencesOfString(".gif", withString: "")
            questionImage.setImageNamed(aImageNew)
            questionImage.setHidden(true)
        }
        self.answerLabel.setHidden(true)
        answerIsHidden = true */
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
