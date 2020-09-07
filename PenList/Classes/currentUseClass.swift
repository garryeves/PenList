//
//  currentUseClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class currentUses: NSObject {
    fileprivate var myCurrentUse: [currentUse] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        getData()
    }
    
    func reload() {
        myCurrentUse.removeAll()
        
        getData()
    }
    
    private func getData() {
        for item in myCloudDB.getCurrentUse() {
            let object = currentUse(passeddateEnded: item.dateEnded,
                                    passeddateStarted: item.dateStarted,
                                    passedinkID: item.inkID,
                                    passednotes: item.notes,
                                    passedpenID: item.penID,
                                    passedrating: item.rating,
                                    passedUseID: item.useID)
            myCurrentUse.append(object)
        }

        sortArrayByName()
    }
    
    func append(_ newItem: currentUse){
        myCurrentUse.append(newItem)
    }

    func sortArrayByName() {
        if myCurrentUse.count > 1 {
            myCurrentUse.sort {
                if $0.dateStarted == $1.dateStarted {
                    return $0.rating < $1.rating
                } else {
                    return $0.dateStarted < $1.dateStarted
                }
            }
        }
    }
    
    var use: [currentUse] {
        get {
            return myCurrentUse
        }
    }
}

class currentUse: NSObject, Identifiable, ObservableObject {
    var useID = UUID()
    var dateEnded = getDefaultDate()
    var dateStarted = Date()
    var inkID = ""
    var notes = ""
    var penID = ""
    var rating: Int64 = 0

    var penName: String {
        get {
            for item in currentPenList.pens {
                if item.myPenID.uuidString == penID {
                    return item.name
                }
            }
            
            return ""
        }
    }
    
    var penManufacturer: String {
        get {
            for item in currentPenList.pens {
                if item.myPenID.uuidString == penID {
                    return item.manufacturer
                }
            }
            
            return ""
        }
    }
    
    var inkName: String {
        get {
            for item in inkList.inks {
                if item.inkID.uuidString == inkID {
                    return item.name
                }
            }
            return ""
        }
    }
    
    var inkManufacturer: String {
        get {
            for item in inkList.inks {
                if item.inkID.uuidString == inkID {
                    return item.manufacturer
                }
            }
            return ""
        }
    }
    
    var inkFamily: String {
        get {
            for item in inkList.inks {
                if item.inkID.uuidString == inkID {
                    return item.inkFamily
                }
            }
            return ""
        }
    }
    
    
    
    
    override init() {
        super.init()
    }
    
    init(passeddateEnded: Date,
         passeddateStarted: Date,
         passedinkID: String,
         passednotes: String,
         passedpenID: String,
         passedrating: Int64,
         passedUseID: String)
    {
        super.init()
        dateEnded = passeddateEnded
        dateStarted = passeddateStarted
        inkID = passedinkID
        notes = passednotes
        penID = passedpenID
        rating = passedrating
        useID = UUID(uuidString: passedUseID)!
    }
    
    init(newPenID: String, newInkID: String) {
        super.init()
        penID = newPenID
        inkID = newInkID
        
        save()
    }

    func save()
    {
        let temp = CurrentUse(dateEnded: dateEnded, dateStarted: dateStarted, inkID: inkID, notes: notes, penID: penID, rating: rating, useID: useID.uuidString)
            
        myCloudDB.saveCurrentUse(temp)
    }
}

struct CurrentUse {
    public var dateEnded: Date
    public var dateStarted: Date
    public var inkID: String
    public var notes: String
    public var penID: String
    public var rating: Int64
    public var useID: String
}

extension CloudKitInteraction {
    private func populateCurrentUse(_ records: [CKRecord]) -> [CurrentUse] {
        var tempArray: [CurrentUse] = Array()
        
        for record in records {
            let tempItem = CurrentUse(dateEnded: decodeDate(record.object(forKey: "dateEnded")),
                                    dateStarted: decodeDate(record.object(forKey: "dateStarted")),
                                    inkID: decodeString(record.object(forKey: "inkID")),
                                    notes: decodeString(record.object(forKey: "notes")),
                                    penID: decodeString(record.object(forKey: "penID")),
                                    rating: decodeInt64(record.object(forKey: "rating")),
                                    useID: decodeString(record.object(forKey: "useID")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getCurrentUse()->[CurrentUse] {
        let predicate = NSPredicate(format: "dateEnded == %@", getDefaultDate() as CVarArg)

        let query = CKQuery(recordType: "currentUse", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()

        return populateCurrentUse(returnArray)
    }

    func saveCurrentUse(_ sourceRecord: CurrentUse) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "useID == \"\(sourceRecord.useID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "currentUse", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.dateEnded, forKey: "dateEnded")
                    record!.setValue(sourceRecord.rating, forKey: "rating")
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
                    let record = CKRecord(recordType: "currentUse")
                    record.setValue(sourceRecord.dateEnded, forKey: "dateEnded")
                    record.setValue(sourceRecord.dateStarted, forKey: "dateStarted")
                    record.setValue(sourceRecord.inkID, forKey: "inkID")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.penID, forKey: "penID")
                    record.setValue(sourceRecord.rating, forKey: "rating")
                    record.setValue(sourceRecord.useID, forKey: "useID")
                    
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

