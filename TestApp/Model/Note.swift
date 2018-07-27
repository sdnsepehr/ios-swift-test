//
//  Note.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit
import CoreData

class Note: NSManagedObject {
    
    class func createNote(title: String, details: String?, isalertOn: Bool = false, alertDate: Date?, color: UIColor = Style.lightGrayColor, in context: NSManagedObjectContext) throws -> Note {
        
        let note = Note(context: context);
        note.title = title;
        note.details = details;
        note.isDone = false;
        note.isAlertOn = isalertOn;
        note.alertDate = alertDate == nil ? nil : alertDate!;
        note.colorHex = color.toHex;
        note.updatedDate = Date();
        
        return note;
    }
    
    func updatedDateString() -> String? {
        guard let date = self.updatedDate else { return nil }
        let formatter = DateFormatter();
        formatter.dateFormat = "MMM d, yyyy ' ' h:mm a";
        return formatter.string(from: date as Date);
    }
    
    func alertDateString() -> String? {
        guard let date = self.alertDate else { return nil }
        let formatter = DateFormatter();
        formatter.dateFormat = "EE h:mm a ' - ' MMM d, yyyy";
        return formatter.string(from: date as Date);
    }
    
    func updateAlertDate(date: Date?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.alertDate = date;
        self.isAlertOn = date != nil;
        appDelegate.saveContext();
    }
    
    func updateDetails(updatedDetails: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.details = updatedDetails;
        appDelegate.saveContext();
    }
    
    func setDone() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.isDone = true;
        self.isAlertOn = false;
        self.alertDate = nil;
        appDelegate.saveContext();
    }
    
    func delete(in context: NSManagedObjectContext)  {
        context.delete(self);
        try? context.save()
    }
}
