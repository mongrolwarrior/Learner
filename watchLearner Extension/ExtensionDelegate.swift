//
//  ExtensionDelegate.swift
//  watchLearner Extension
//
//  Created by Andrew Amos on 9/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        self.setupWatchConnectivity()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
        let session  = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        }
    }
}