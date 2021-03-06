//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

enum TaskType: Int {
	
	case Issue = 0
	case StartDay = 1
	case Scrum = 2
	case Lunch = 3
	case Meeting = 4
	case GitCommit = 5
}

enum TaskSubtype: Int {
	
//	case IssueBegin = 0
	case IssueEnd = 1
//	case ScrumBegin = 2
	case ScrumEnd = 3
//	case LunchBegin = 4
	case LunchEnd = 5
//	case MeetingBegin = 6
	case MeetingEnd = 7
	case GitCommitEnd = 8
}

struct Task {
	
	var endDate: NSDate
	var notes: String?
	var taskNumber: String?
	var taskType: NSNumber
	var taskId: String
}

extension Task {
	
    init () {
        self.endDate = NSDate()
        self.taskType = TaskType.Issue.rawValue
        self.taskId = String.random()
    }
    
	init (dateEnd: NSDate, type: TaskType) {
		
		self.endDate = dateEnd
		self.taskNumber = nil
		self.taskType = type.rawValue
        self.taskId = String.random()
		
		switch (type) {
			case TaskType.Issue:	self.notes = ""
			case TaskType.StartDay:	self.notes = "Working day started"
			case TaskType.Scrum:	self.notes = "Scrum meeting"
			case TaskType.Lunch:	self.notes = "Lunch break"
			case TaskType.Meeting:	self.notes = "Internal meeting"
			case TaskType.GitCommit:self.notes = ""
		}
	}
	
	init (subtype: TaskSubtype) {
		
        self.endDate = NSDate()
        self.taskId = String.random()
        
		switch (subtype) {
			case .IssueEnd:		self.taskType = TaskType.Issue.rawValue
			case .ScrumEnd:		self.taskType = TaskType.Scrum.rawValue
			case .LunchEnd:		self.taskType = TaskType.Lunch.rawValue
			case .MeetingEnd:	self.taskType = TaskType.Meeting.rawValue
			case .GitCommitEnd:	self.taskType = TaskType.GitCommit.rawValue
		}
	}
}

typealias TaskCreationData = (
    dateEnd: NSDate,
    taskNumber: String,
    notes: String
)
