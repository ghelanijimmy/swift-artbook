//
//  data.swift
//  ArtBookProject
//
//  Created by Jimmy Ghelani on 2023-09-17.
//

import Foundation
import UIKit
import CoreData

struct AppData {
    static func getData() -> [Paintings]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = Paintings.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            return try context.fetch(request)
        } catch {
            print("Couldn't fetch the dat: \(error)")
        }
        return nil
    }
    
    static func getDataWithContext(with predicate: String, for arg: CVarArg) -> (results: [Paintings]?, context: NSManagedObjectContext)? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = Paintings.fetchRequest()
        request.predicate = NSPredicate(format: predicate, arg)
        request.returnsObjectsAsFaults = false
        do {
            return try (results: context.fetch(request), context: context)
        } catch {
            print("Couldn't fetch the dat: \(error)")
        }
        return nil
    }
    
    static func saveData(for name: String?, by creator: String?, in year: String?, with imageView: UIImageView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let painting = Paintings(context: context)
        painting.name = name
        painting.artist = creator
        
        if let year = Int32(year!) {
            painting.year = year
        }
        
        painting.id = UUID()
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        painting.image = data
        
        do {
            try context.save()
        } catch {
            print("Error saving data: \(error)")
        }
    }
}
