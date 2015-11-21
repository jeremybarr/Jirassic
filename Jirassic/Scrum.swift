//
//  Scrum.swift
//  Jirassic
//
//  Created by Baluta Cristian on 09/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Scrum: NSObject {

	func exists (tasks: [Task]) -> Bool {
		
		var scrumExists = false
		for task in tasks {
			if task.taskType == TaskType.Scrum.rawValue {
				scrumExists = true
				break
			}
		}
		return scrumExists
	}
}
