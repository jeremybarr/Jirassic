//
//  PTask.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

let kDateStartKey = "date_task_started"
let kDateFinishKey = "date_task_finished"
let kNotesKey = "notes"
let kIssueTypeKey = "issue_type"
let kIssueIdKey = "issue_id"
let kTaskTypeKey = "task_type"
let kUserKey = "user"

public class PTask: PFObject, PFSubclassing {
	
	dynamic public var date_task_started: NSDate? {
		get {
			if let value: AnyObject = objectForKey(kDateStartKey) {
				switch value {
					case _ as NSNull:
						return nil
					case let value as NSDate:
						return value
					default:
						fatalError("unexpected object")
				}
			}
			return nil
		}
		set {
			if let value = newValue {
				setObject(value, forKey: kDateStartKey)
			} else {
				setObject(NSNull(), forKey: kDateStartKey)
			}
		}
	}
	
    dynamic public var date_task_finished: NSDate? {
        get {
			if let value: AnyObject = objectForKey(kDateFinishKey) {
				switch value {
					case _ as NSNull:
						return nil
					case let value as NSDate:
						return value
					default:
						fatalError("unexpected object")
				}
			}
			return nil
        }
        set {
			if let value = newValue {
				setObject(value, forKey: kDateFinishKey)
			} else {
				setObject(NSNull(), forKey: kDateFinishKey)
			}
        }
    }
    
    dynamic public var notes: String? {
        get {
            return objectForKey(kNotesKey) as! String?
        }
        set {
			if let value = newValue {
				setObject(value, forKey: kNotesKey)
			}
        }
    }
	
	dynamic public var issue_type: String? {
		get {
			return objectForKey(kIssueTypeKey) as! String?
		}
		set {
			if let value = newValue {
				setObject(value, forKey: kIssueTypeKey)
			}
		}
	}
	
	dynamic public var issue_id: String? {
		get {
			return objectForKey(kIssueIdKey) as! String?
		}
		set {
			if let value = newValue {
				setObject(value, forKey: kIssueIdKey)
			}
		}
	}
	
	dynamic public var task_type: NSNumber? {
		get {
			return objectForKey(kTaskTypeKey) as! NSNumber?
		}
		set {
			if let value = newValue {
				setObject(value, forKey: kTaskTypeKey)
			}
		}
	}
	
	var user: PUser? {
		get {
			return objectForKey(kUserKey) as! PUser?
		}
		set {
			if let value = newValue {
				setObject(value, forKey: kUserKey)
			}
		}
	}
	
	public class func parseClassName() -> String {
		return "Task"
	}
}
