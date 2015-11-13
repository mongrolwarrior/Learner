//
//  Extensions.swift
//  Learner
//
//  Created by Andrew Amos on 7/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import Foundation

// to allow use of .stringByAppendingPathComponent method in Swift 2
extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}

extension NSDate {
    var formatted:String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/M/yyyy - H:mm"
        return formatter.stringFromDate(self)
    }
    func formattedWith(format:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension String {
    var asDate:NSDate! {
        let styler = NSDateFormatter()
        styler.dateFormat = "dd/M/yyyy - H:mm"
        return styler.dateFromString(self)!
    }
    func asDateFormattedWith(format:String) -> NSDate! {
        let styler = NSDateFormatter()
        styler.dateFormat = format
        return styler.dateFromString(self)!
    }
    
}