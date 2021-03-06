//
//  CoreDataManager.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/04/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData

class CoreDataRepository {
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        RCLog(urls)
        return urls.last as NSURL!
//        return (urls.last as NSURL!).URLByAppendingPathComponent("Jirassic")
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Jirassic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Jirassic.sqlite")
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            return coordinator
        } catch _ {
            return nil
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        guard let coordinator = self.persistentStoreCoordinator() else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch _ {
                    
                }
            }
        }
    }
}

extension CoreDataRepository {
    
    private func queryWithPredicate<T:NSManagedObject> (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        
        guard let context = managedObjectContext else {
            return []
        }
        
        let request = NSFetchRequest(entityName: String(T))
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            let results = try context.executeFetchRequest(request)
            return results as! [T]
        } catch _ {
            return []
        }
    }
}

extension CoreDataRepository {
    
    private func taskFromCTask (ctask: CTask) -> Task {
        
        return Task(endDate: ctask.endDate!,
                    notes: ctask.notes,
                    taskNumber: ctask.taskNumber,
                    taskType: ctask.taskType!,
                    taskId: ctask.taskId!
        )
    }
    
    private func tasksFromCTasks (ctasks: [CTask]) -> [Task] {
        
        var tasks = [Task]()
        for ctask in ctasks {
            tasks.append(self.taskFromCTask(ctask))
        }
        
        return tasks
    }
    
    private func ctaskFromTask (task: Task) -> CTask {
        
        let taskPredicate = NSPredicate(format: "taskId == %@", task.taskId)
        let tasks: [CTask] = queryWithPredicate(taskPredicate, sortDescriptors: nil)
        var ctask: CTask? = tasks.first
        if ctask == nil {
            ctask = NSEntityDescription.insertNewObjectForEntityForName(String(CTask),
                    inManagedObjectContext: managedObjectContext!) as? CTask
        }
        if ctask?.taskId == nil {
            ctask?.taskId = task.taskId
        }
        
        return updatedCTask(ctask!, withTask: task)
    }
    
    // Update only updatable properties. taskId can't be updated
    private func updatedCTask (ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.taskNumber = task.taskNumber
        ctask.taskType = task.taskType
        ctask.notes = task.notes
        ctask.endDate = task.endDate
        
        return ctask
    }
    
}

extension CoreDataRepository: Repository {
    
    func currentUser() -> User {
        
        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        let cusers: [CUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
        if let cuser = cusers.last {
            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func logout() {
        
        guard let context = managedObjectContext else {
            return
        }
        
        if #available(OSX 1000.11, *) {
            // TODO: This seems not to work under 10.11
            let fetchRequest = NSFetchRequest(entityName: String(CTask))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try persistentStoreCoordinator()?.executeRequest(deleteRequest, withContext: context)
            } catch let error as NSError {
                RCLog(error)
            }
        } else {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName(String(CTask), inManagedObjectContext: context)
            fetchRequest.includesPropertyValues = false
            do {
                if let results = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    for result in results {
                        context.deleteObject(result)
                    }
                    try context.save()
                }
            } catch {
                
            }
        }
    }
    
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void) {
        
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(nil, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (day: NSDate) -> [Task] {
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay(), day.endOfDay())
            ])
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(compoundPredicate, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = NSPredicate(format: "lastModifiedDate == nil")
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func deleteTask (task: Task, completion: ((success: Bool) -> Void)) {
        
        guard let context = managedObjectContext else {
            return
        }
        
        let ctask = ctaskFromTask(task)
        context.deleteObject(ctask)
        saveContext()
        completion(success: true)
    }
    
    func saveTask (task: Task, completion: (success: Bool) -> Void) -> Task {
        
        let ctask = ctaskFromTask(task)
        saveContext()
        
        return taskFromCTask(ctask)
    }
}
