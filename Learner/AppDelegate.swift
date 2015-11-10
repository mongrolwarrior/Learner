//
//  AppDelegate.swift
//  Learner
//
//  Created by Andrew Amos on 7/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    
    lazy var earliestActiveQuestionPredicate: NSPredicate = {
        var predicate = NSPredicate(format: "current = YES AND lastanswered<= %@", NSDate(timeIntervalSinceNow: -3600))
        return predicate
        
    }()
    
    private func setupWatchConnectivity() {
        // 1
        if WCSession.isSupported() {
        // 2
        let session = WCSession.defaultSession()
        // 3
        session.delegate = self
        // 4
        session.activateSession()
        }
    }
    
    func recordAnswer(qid: Int32, accuracy: Bool) -> NSDate {
        var questions = [Questions]()
        let request = NSFetchRequest(entityName: "Questions")
        request.predicate = NSPredicate(format: "qid = %d", qid)
        do {
            questions = try managedObjectContext.executeFetchRequest(request) as! [Questions]
        } catch _ as NSError {
            print("getRequest error")
        }
        let currentQuestion = questions[0]
        
        let entity = NSEntityDescription.entityForName("AnswerLog", inManagedObjectContext: managedObjectContext)
        let answerLog = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        answerLog.setValue(currentQuestion.qid, forKey: "qid")
        answerLog.setValue(NSDate(), forKey: "dateanswered")
        answerLog.setValue(accuracy, forKey: "accuracy")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Couldn't save \(error), \(error.userInfo)")
        }
        
        let correctionConstant = currentQuestion.correction ?? 0.0  // "Nil coalescing operator" assigns the left hand side if the conditional is not nil, or the right hand side
        var dateLatency: NSTimeInterval = currentQuestion.nextdue!.timeIntervalSinceNow
        var timeToNextDue = NSTimeInterval()
        
        if let dateTime = currentQuestion.lastanswered?.timeIntervalSinceNow {
            if accuracy {
                timeToNextDue = fmax((2.0-correctionConstant.doubleValue), 1.1) *  fabs(dateTime)
             //   changeNextDue(NSDate(timeIntervalSinceNow:fmax((2.0-correctionConstant.doubleValue), 1.1) *  fabs(dateTime)))
            } else {
                timeToNextDue = fabs(dateTime)*0.1
            //    changeNextDue(NSDate(timeIntervalSinceNow:fabs(dateTime)*0.1))
            }
        } else {
            timeToNextDue = 600
//            changeNextDue(NSDate(timeIntervalSinceNow: 600))
        }
        
        
        do {
            currentQuestion.nextdue = NSDate(timeIntervalSinceNow: timeToNextDue)
            currentQuestion.lastanswered = NSDate()
            try managedObjectContext.save()
        } catch _ as NSError {
            print("getRequest error")
        }
        
        if dateLatency < -18000 {
            dateLatency = 300.0
        } else if dateLatency < 0 {
            dateLatency = 600 + dateLatency/60
        } else if dateLatency < 7200 {
            dateLatency = 600 + dateLatency/6
        } else {
            dateLatency = 1800
       //     triggerNewQuestion()
        }
        scheduleLocal(self, timeToSend: dateLatency)
   //     self.updateCurrentQuestion(accuracy)
     //   setQuestion()
        return NSDate(timeIntervalSinceNow: timeToNextDue) // NSDate(timeIntervalSinceNow: timeToNextDue)
    }
    
    func scheduleLocal(sender: AnyObject, timeToSend: NSTimeInterval) {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            let navigationController = window!.rootViewController as! UINavigationController
            
            let activeViewCont = navigationController.visibleViewController
            
            activeViewCont!.presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: timeToSend)
        notification.alertBody = "Answer question"
        notification.alertAction = "Answer question"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        var questions = [Questions]()
        var reply = [String: AnyObject]()
        let request = NSFetchRequest(entityName: "Questions")
        
        
        let messageType = message["messageType"] as? String
        
        var tester = "this"
        if !(messageType == nil) {
            if !messageType!.isEmpty {
                switch messageType! {
                    case "sendAnswer":
                        let qid = message["qid"] as! NSNumber
                        request.predicate = NSPredicate(format: "qid = %d", qid.intValue)
                        do {
                            questions = try managedObjectContext.executeFetchRequest(request) as! [Questions]
                        } catch _ as NSError {
                            print("getRequest error")
                        }
                        if !questions.isEmpty {
                            let accuracy = message["accuracy"] as! Bool
                            reply["nextdue"] = self.recordAnswer(qid.intValue, accuracy: accuracy).formatted //questions[0].nextdue!.formatted
                        } else {
                            reply["nextdue"] = "nil"
                    }
                    
                    case "getQuestion":
                        request.predicate = earliestActiveQuestionPredicate
                        request.sortDescriptors = [NSSortDescriptor(key: "nextdue", ascending: true)]
                        do {
                            questions = try managedObjectContext.executeFetchRequest(request) as! [Questions]
                        } catch _ as NSError {
                            print("getRequest error")
                        }
                        
                        if questions[0].qid != nil {
                            reply["qid"] = questions[0].qid!
                        }
                        if questions[0].question != nil {
                            reply["question"] = questions[0].question!
                        }
                        if questions[0].answer != nil {
                            reply["answer"] = questions[0].answer!
                        }
                        if questions[0].aPictureName != nil {
                            if !questions[0].aPictureName!.isEmpty {
                                tester = "second"
                                reply["aImage"] = questions[0].aPictureName!
                            } else {
                                tester = "third"
                                reply["aImage"] = ""
                            }
                        } else {
                            reply["aImage"] = ""
                        }
                        if questions[0].qPictureName != nil {
                            if !questions[0].qPictureName!.isEmpty {
                                reply["qImage"] = questions[0].qPictureName!
                            } else {
                                reply["qImage"] = ""
                            }
                        } else {
                            reply["qImage"] = ""
                    }
                default:
                    print("default")
                }
            }
        }
        
 //       let replytemp = ["question":reply["question"]!, "answer":reply["answer"]!, "aImage": tester, "qImage":"qImage", "qid": questions[0].qid!]//NSNumber(int: 1)]
        
       replyHandler(reply)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let viewController = window!.rootViewController as! ViewController
        viewController.managedContext = managedObjectContext
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        self.setupWatchConnectivity()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "SlyLie.Learner" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Learner", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

