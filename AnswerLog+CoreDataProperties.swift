//
//  AnswerLog+CoreDataProperties.swift
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

extension AnswerLog {

    @NSManaged var accuracy: NSNumber?
    @NSManaged var dateanswered: NSDate?
    @NSManaged var qid: NSNumber?

}
