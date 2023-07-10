//
//  TodoService.swift
//  CoreData-Demo
//
//  Created by Pushkar Deshmukh on 10/07/23.
//

import Foundation
import CoreData

protocol TodoStoreProtocol {
    var container: NSPersistentContainer { get set }
    
    func getAllItems(completion: @escaping (Result<[ToDoListItem], Error>) -> Void)
    func createItem(name: String)
    func deleteItem(item: ToDoListItem)
    func update(item: ToDoListItem, newName: String)
}

class TodoStore: TodoStoreProtocol {
    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData_Demo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    
    func getAllItems(completion: @escaping (Result<[ToDoListItem], Error>) -> Void) {
        do {
            let models = try viewContext.fetch(ToDoListItem.fetchRequest())

            DispatchQueue.main.async {
                completion(.success(models))
            }

        } catch {
            completion(.failure(error))
        }
    }
    
    func createItem(name: String) {
        do {
            let model = ToDoListItem(context: container.viewContext)
            model.name = name
            try viewContext.save()
        } catch {
            
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        viewContext.delete(item)
        
        do {
            try  viewContext.save()
        } catch {
            
        }
        
    }
    
    func update(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try viewContext.save()
        } catch {
            
        }
        
    }
}
