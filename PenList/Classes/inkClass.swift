//
//  inkClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class inks: NSObject {
    fileprivate var myInks: [ink] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getInks() {
            let object = ink(passedinkID: item.inkID,
                             passedcolour: item.colour,
                             passedinkFamily: item.inkFamily,
             //                passedinkType: item.inkType,
                             passedmanID: item.manID,
                             passedname: item.name,
                             passednotes: item.notes)
            myInks.append(object)
        }
        
        sortArrayByName()
    }
    
    init(manID: String) {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getInks(manID: manID) {
            let object = ink(passedinkID: item.inkID,
                             passedcolour: item.colour,
                             passedinkFamily: item.inkFamily,
           //                  passedinkType: item.inkType,
                             passedmanID: item.manID,
                             passedname: item.name,
                             passednotes: item.notes)
            myInks.append(object)
        }
        
        sortArrayByName()
    }
    
    func append(_ newItem: ink){
        myInks.append(newItem)
    }

    func sortArrayByName() {
        if myInks.count > 1 {
            myInks.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var inks: [ink] {
        get {
            return myInks
        }
    }
}

class ink: NSObject, Identifiable, ObservableObject {
    var inkID = UUID()
    var colour = ""
    var inkFamily = ""
 //   @Published var inkType = ""
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
    
    var inkItems : [myInk] {
        get {
            return currentInkList.inks.filter { $0.inkID == inkID.uuidString }
        }
    }

    override init() {
        super.init()
    }
    
    init(passedinkID: String,
         passedcolour: String,
         passedinkFamily: String,
       //  passedinkType: String,
         passedmanID: String,
         passedname: String,
         passednotes: String)
    {
        super.init()
        inkID = UUID(uuidString: passedinkID)!
        colour = passedcolour
        inkFamily = passedinkFamily
     //   inkType = passedinkType
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
        
        let _ = myInk(passedinkID: inkID.uuidString, passednotes: notes)
    }

    func save()
    {
        let temp = Ink(colour: colour,
                       inkFamily: inkFamily,
                       inkID: inkID.uuidString,
                    //   inkType: inkType,
                       manID: manID,
                       name: name,
                       notes: notes)
            
        myCloudDB.saveInk(temp)
    }
}

struct Ink {
    public var colour: String
    public var inkFamily: String
    public var inkID: String
  //  public var inkType: String
    public var manID: String
    public var name: String
    public var notes: String
}

extension CloudKitInteraction {
    private func populateInk(_ records: [CKRecord]) -> [Ink] {
        var tempArray: [Ink] = Array()
        
        for record in records {
            let tempItem = Ink(colour: decodeString(record.object(forKey: "colour")),
                               inkFamily: decodeString(record.object(forKey: "inkFamily")),
                               inkID: decodeString(record.object(forKey: "inkID")),
                         //      inkType: decodeString(record.object(forKey: "inkType")),
                               manID: decodeString(record.object(forKey: "manID")),
                               name: decodeString(record.object(forKey: "name")),
                               notes: decodeString(record.object(forKey: "notes")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getInks()->[Ink] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "ink", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateInk(returnArray)
    }
    
    func getInks(manID: String)->[Ink] {
        let predicate = NSPredicate(format: "manID == \"\(manID)\"") // better be accurate to get only the record you need

        let query = CKQuery(recordType: "ink", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateInk(returnArray)
    }

    func saveInk(_ sourceRecord: Ink) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "inkID == \"\(sourceRecord.inkID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ink", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.colour, forKey: "colour")
              //      record!.setValue(sourceRecord.inkType, forKey: "inkType")
                    record!.setValue(sourceRecord.manID, forKey: "manID")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.inkFamily, forKey: "inkFamily")
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
                    let record = CKRecord(recordType: "ink")
                    record.setValue(sourceRecord.colour, forKey: "colour")
                    record.setValue(sourceRecord.inkID, forKey: "inkID")
               //     record.setValue(sourceRecord.inkType, forKey: "inkType")
                    record.setValue(sourceRecord.manID, forKey: "manID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.inkFamily, forKey: "inkFamily")
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

