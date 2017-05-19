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
    
    func saveWinLoses() {
               let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context)
        entity.setValue(Set1.wins, forKey: "wins")
        entity.setValue(Set1.loses,forKey: "loses")
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func loadWinLoses() {
        var wins = Int()
        var loses = Int()
        var resultsBoost = [AnyObject]()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.persistentContainer.viewContext
        
        let requestBoost = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        
        do { resultsBoost = try context.fetch(requestBoost) } catch  {
            print("Could not cache the response \(error)")
        }
        
        
        if resultsBoost.last != nil {
            wins = (resultsBoost.last!.value(forKeyPath: "wins") as? Int)!
            loses = (resultsBoost.last!.value(forKeyPath: "loses") as? Int)!
        }
        Set1.wins = wins
        Set1.loses = loses
    }
    
    func saveState() {
        GameCenter.shared.addDataToGameCenter(wins: Set1.wins)
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Save")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
        
        let entityGameState = NSEntityDescription.insertNewObject(forEntityName: "Save", into: context)
        
        entityGameState.setValue(Set1.winState, forKey: "isWinMode")
        entityGameState.setValue(Set1.atBatRawValue, forKey: "atBatRawValue")
        entityGameState.setValue(Set1.onDeckRawValue, forKey: "onDeckRawValue")
        entityGameState.setValue(Set1.buildableRawValue, forKey: "buildableRawValue")
        entityGameState.setValue(Set1.indexBuildable, forKey: "indexBuildable")
        entityGameState.setValue(Set1.indexStart, forKey: "indexStart")
        entityGameState.setValue(Set1.startRawValue, forKey: "startRawValue")
        entityGameState.setValue(Set1.pileAmount, forKey: "pileAmount")

        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    func loadState() {
print("entered load")
        var resultsSave = [AnyObject]()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.persistentContainer.viewContext
        
        let requestState = NSFetchRequest<NSFetchRequestResult>(entityName: "Save")
        
        do { resultsSave = try context.fetch(requestState) } catch  {
            print("Could not cache the response \(error)")
        }
        
        print(resultsSave)
        if resultsSave.last != nil {
            Set1.winState = (resultsSave.last!.value(forKeyPath: "isWinMode") as? Bool)!
            Set1.atBatRawValue = (resultsSave.last!.value(forKeyPath: "atBatRawValue") as? [String])!
            Set1.onDeckRawValue = (resultsSave.last!.value(forKeyPath: "onDeckRawValue") as? [String])!
            Set1.buildableRawValue = (resultsSave.last!.value(forKeyPath: "buildableRawValue") as? [String])!
            Set1.indexBuildable = (resultsSave.last!.value(forKeyPath: "indexBuildable") as? [Int])!
            Set1.startRawValue = (resultsSave.last!.value(forKeyPath: "startRawValue") as? [String])!
            Set1.indexStart = (resultsSave.last!.value(forKeyPath: "indexStart") as? [Int])!
            Set1.pileAmount = (resultsSave.last!.value(forKeyPath: "pileAmount") as? Int)!
            print(Set1.winState)
            print(Set1.atBatRawValue)
        }

    }
    
    
}
