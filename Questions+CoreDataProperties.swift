//
//  Questions+CoreDataProperties.swift
//  Learner
//
//  Created by Andrew Amos on 7/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Questions {

    @NSManaged var answer: String?
    @NSManaged var aPicture: NSData?
    @NSManaged var aPictureName: String?
    @NSManaged var aSound: String?
    @NSManaged var correction: NSNumber?
    @NSManaged var current: NSNumber?
    @NSManaged var datecreated: NSDate?
    @NSManaged var lastanswered: NSDate?
    @NSManaged var nextdue: NSDate?
    @NSManaged var qid: NSNumber?
    @NSManaged var qPicture: NSData?
    @NSManaged var qPictureName: String?
    @NSManaged var qSound: String?
    @NSManaged var question: String?

}
