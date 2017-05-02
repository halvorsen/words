//
//  LoadSaveCoreData.swift
//  Fooble
//
//  Created by Aaron Halvorsen on 1/4/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LoadSaveCoreData {
    
    static let sharedInstance = LoadSaveCoreData()
    
    func saveBoost(amount: Int) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "IAP", into: context)
        entity.setValue(amount, forKey: "boost")
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func loadBoost() -> Int? {
        var amount = Int()
        var resultsBoost = [AnyObject]()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.persistentContainer.viewContext
        
        let requestBoost = NSFetchRequest<NSFetchRequestResult>(entityName: "IAP")
        
        do { resultsBoost = try context.fetch(requestBoost) } catch  {
            print("Could not cache the response \(error)")
        }
        
        
        if resultsBoost.last != nil {
        return resultsBoost.last!.value(forKeyPath: "boost") as? Int
        } else {
            return nil
        }
        
    }
    
    
    
}
