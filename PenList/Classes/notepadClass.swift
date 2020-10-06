//
//  notepadClass.swift
//  PenList
//
//  Created by Garry Eves on 11/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class notepads: NSObject {
    fileprivate var myNotepads: [notepad] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getNotepads() {
            let object = notepad(passednotepadID: item.notepadID,
                             passedmanID: item.manID,
                             passedname: item.name,
                             passednotes: item.notes)
            myNotepads.append(object)
        }
        
        sortArrayByName()
    }
    
    init(manID: String) {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getNotepads(manID: manID) {
            let object = notepad(passednotepadID: item.notepadID,
                             passedmanID: item.manID,
                             passedname: item.name,
                             passednotes: item.notes)
            myNotepads.append(object)
        }
        
        sortArrayByName()
    }
    
    func append(_ newItem: notepad){
        myNotepads.append(newItem)
    }

    func sortArrayByName() {
        if myNotepads.count > 1 {
            myNotepads.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var notepads: [notepad] {
        get {
            return myNotepads
        }
    }
}

class notepad: NSObject, Identifiable, ObservableObject {
    var notepadID = UUID()
    var manID = ""
    var name = ""
    var notes = ""
    var isNew = true

    var manufacturer: String {
        get {
            for item in manufacturerList.manufacturers {
                if item.manID.uuidString == manID {
                    return item.name
                }
            }
            
            return ""
        }
    }
    
    var notepadItems : [myNotepad] {
        get {
            return currentNotepadList.notepads.filter { $0.notepadID == notepadID.uuidString }
        }
    }

    override init() {
        super.init()
    }
    
    init(passednotepadID: String,
         passedmanID: String,
         passedname: String,
         passednotes: String)
    {
        super.init()
        notepadID = UUID(uuidString: passednotepadID)!
        manID = passedmanID
        name = passedname
        notes = passednotes
        isNew = false
    }
    
    init(passedmanID: String,
         passedname: String)
    {
        super.init()

        manID = passedmanID
        name = passedname
        isNew = true
        
        save()
    }
    
    func newInk(passedmanID: String,
                passedname: String,
                passednotes: String)
    {
        manID = passedmanID
        name = passedname
        notes = passednotes
        isNew = false

        save()
        
        let _ = myNotepad(passednotepadID: notepadID.uuidString, passednotes: notes)
    }

    func save()
    {
        let temp = Notepad(notepadID: notepadID.uuidString,
                           manID: manID,
                           name: name,
                           notes: notes)
            
        myCloudDB.saveNotepad(temp)
    }
}

struct Notepad {
    public var notepadID: String
    public var manID: String
    public var name: String
    public var notes: String
}

extension CloudKitInteraction {
    private func populateNotepad(_ records: [CKRecord]) -> [Notepad] {
        var tempArray: [Notepad] = Array()
        
        for record in records {
            let tempItem = Notepad(notepadID: decodeString(record.object(forKey: "notepadID")),
                                   manID: decodeString(record.object(forKey: "manID")),
                                   name: decodeString(record.object(forKey: "name")),
                                   notes: decodeString(record.object(forKey: "notes")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getNotepads()->[Notepad] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "Notepads", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateNotepad(returnArray)
    }
    
    func getNotepads(manID: String)->[Notepad] {
        let predicate = NSPredicate(format: "manID == \"\(manID)\"") // better be accurate to get only the record you need

        let query = CKQuery(recordType: "Notepads", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateNotepad(returnArray)
    }

    func saveNotepad(_ sourceRecord: Notepad) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "notepadID == \"\(sourceRecord.notepadID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Notepads", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.manID, forKey: "manID")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.notes, forKey: "notes")

                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        } else {
                            if debugMessages {
                                NSLog("Successfully updated record!")
                            }
                            sem.signal()
                        }
                    })
                } else {  // Insert
                    let record = CKRecord(recordType: "Notepads")
                    record.setValue(sourceRecord.notepadID, forKey: "notepadID")
                    record.setValue(sourceRecord.manID, forKey: "manID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.notes, forKey: "notes")

                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        } else {
                            if debugMessages {
                                NSLog("Successfully saved record!")
                            }
                            sem.signal()
                        }
                    })
                }
            }
        })
        sem.wait()
    }
}


