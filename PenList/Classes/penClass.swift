//
//  penClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class pens: NSObject {
    fileprivate var myPenList: [pen] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getPens() {
            let object = pen(passedPenID: item.penID,
                             passedfilingSystem: item.filingSystem,
                             passedname: item.name,
                             passedmanID: item.manID,
                             passednotes: item.notes,
                             passeddiameterBody: item.diameterBody,
                             passeddiameterGrip: item.diameterGrip,
                             passeddiameterCap: item.diameterCap,
                             passedlengthBody: item.lengthBody,
                             passedlengthCap: item.lengthCap,
                             passedlengthClosed: item.lengthClosed,
                             passedweightBody: item.weightBody,
                             passedweightCap: item.weightCap,
                             passedweightTotal: item.weightTotal)
            
            myPenList.append(object)
        }
        
        sortArrayByName()
    }
    
    init(manID: String) {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getPens(manID: manID) {
            let object = pen(passedPenID: item.penID,
                             passedfilingSystem: item.filingSystem,
                             passedname: item.name,
                             passedmanID: item.manID,
                             passednotes: item.notes,
                             passeddiameterBody: item.diameterBody,
                             passeddiameterGrip: item.diameterGrip,
                             passeddiameterCap: item.diameterCap,
                             passedlengthBody: item.lengthBody,
                             passedlengthCap: item.lengthCap,
                             passedlengthClosed: item.lengthClosed,
                             passedweightBody: item.weightBody,
                             passedweightCap: item.weightCap,
                             passedweightTotal: item.weightTotal)
            
            myPenList.append(object)
        }
        
        sortArrayByName()
    }
    
    func append(_ newItem: pen){
        myPenList.append(newItem)
    }

    func sortArrayByName() {
        if myPenList.count > 1 {
            myPenList.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var pens: [pen] {
        get {
            return myPenList
        }
    }
}

class pen: NSObject, Identifiable, ObservableObject {
    var penID = UUID()
    var fillingSystem = ""
    var name = ""
    var notes = ""
    var manID = ""
    var diameterBody = ""
    var diameterGrip = ""
    var diameterCap = ""
    var lengthBody = ""
    var lengthCap = ""
    var lengthClosed = ""
    var weightBody = ""
    var weightCap = ""
    var weightTotal = ""
    
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
    
    var penItems : [myPen] {
        get {
            return currentPenList.pens.filter { $0.penID == penID.uuidString }
        }
    }
    
    override init() {
        super.init()
    }
    
    init(passedPenID: String,
         passedfilingSystem: String,
         passedname: String,
         passedmanID: String,
         passednotes: String,
         passeddiameterBody: String,
         passeddiameterGrip: String,
         passeddiameterCap: String,
         passedlengthBody: String,
         passedlengthCap: String,
         passedlengthClosed: String,
         passedweightBody: String,
         passedweightCap: String,
         passedweightTotal: String) {
        super.init()
        penID = UUID(uuidString: passedPenID)!
        fillingSystem = passedfilingSystem
        manID = passedmanID
        name = passedname
        notes = passednotes
        diameterBody = passeddiameterBody
        diameterGrip = passeddiameterGrip
        diameterCap = passeddiameterCap
        lengthBody = passedlengthBody
        lengthCap = passedlengthCap
        lengthClosed = passedlengthClosed
        weightBody = passedweightBody
        weightCap = passedweightCap
        weightTotal = passedweightTotal
        
        isNew = false
    }
    
    func newPen(passedname: String,
                passedmanID: String,
                passednotes: String) {

        manID = passedmanID
        name = passedname
        notes = passednotes
        
        save()
        
        isNew = false
        
        let _ = myPen(passedpenID: penID.uuidString, passedname: name, passednotes: notes)
    }


    func save()
    {
        let temp = Pen(filingSystem: fillingSystem,
                       manID: manID,
                       name: name,
                       notes: notes,
                       penID: penID.uuidString,
                       diameterBody: diameterBody,
                       diameterGrip: diameterGrip,
                       diameterCap: diameterCap,
                       lengthBody: lengthBody,
                       lengthCap: lengthCap,
                       lengthClosed: lengthClosed,
                       weightBody: weightBody,
                       weightCap: weightCap,
                       weightTotal: weightTotal)
            
        myCloudDB.savePen(temp)
    }
}

struct Pen {
    public var filingSystem: String
    public var manID: String
    public var name: String
    public var notes: String
    public var penID: String
    public var diameterBody: String
    public var diameterGrip: String
    public var diameterCap: String
    public var lengthBody: String
    public var lengthCap: String
    public var lengthClosed: String
    public var weightBody: String
    public var weightCap: String
    public var weightTotal: String
}

extension CloudKitInteraction {
    private func populatePen(_ records: [CKRecord]) -> [Pen] {
        var tempArray: [Pen] = Array()
        
        for record in records {
            let tempItem = Pen(filingSystem: decodeString(record.object(forKey: "filingSystem")),
                               manID: decodeString(record.object(forKey: "manID")),
                               name: decodeString(record.object(forKey: "name")),
                               notes: decodeString(record.object(forKey: "notes")),
                               penID: decodeString(record.object(forKey: "penID")),
                               diameterBody: decodeString(record.object(forKey: "diameterBody")),
                               diameterGrip: decodeString(record.object(forKey: "diameterGrip")),
                               diameterCap: decodeString(record.object(forKey: "diameterCap")),
                               lengthBody: decodeString(record.object(forKey: "lengthBody")),
                               lengthCap: decodeString(record.object(forKey: "lengthCap")),
                               lengthClosed: decodeString(record.object(forKey: "lengthClosed")),
                               weightBody: decodeString(record.object(forKey: "weightBody")),
                               weightCap: decodeString(record.object(forKey: "weightCap")),
                               weightTotal: decodeString(record.object(forKey: "weightTotal")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getPens()->[Pen] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "pen", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populatePen(returnArray)
    }
    
    func getPens(manID: String)->[Pen] {
        let predicate = NSPredicate(format: "manID == \"\(manID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "pen", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populatePen(returnArray)
    }

    func savePen(_ sourceRecord: Pen) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "penID == \"\(sourceRecord.penID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "pen", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.filingSystem, forKey: "filingSystem")
                    record!.setValue(sourceRecord.manID, forKey: "manID")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.notes, forKey: "notes")
                    record!.setValue(sourceRecord.diameterBody, forKey: "diameterBody")
                    record!.setValue(sourceRecord.diameterGrip, forKey: "diameterGrip")
                    record!.setValue(sourceRecord.diameterCap, forKey: "diameterCap")
                    record!.setValue(sourceRecord.lengthBody, forKey: "lengthBody")
                    record!.setValue(sourceRecord.lengthCap, forKey: "lengthCap")
                    record!.setValue(sourceRecord.lengthClosed, forKey: "lengthClosed")
                    record!.setValue(sourceRecord.weightBody, forKey: "weightBody")
                    record!.setValue(sourceRecord.weightCap, forKey: "weightCap")
                    record!.setValue(sourceRecord.weightTotal, forKey: "weightTotal")

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
                    let record = CKRecord(recordType: "pen")
                    record.setValue(sourceRecord.penID, forKey: "penID")
                    record.setValue(sourceRecord.filingSystem, forKey: "filingSystem")
                    record.setValue(sourceRecord.manID, forKey: "manID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.diameterBody, forKey: "diameterBody")
                    record.setValue(sourceRecord.diameterGrip, forKey: "diameterGrip")
                    record.setValue(sourceRecord.diameterCap, forKey: "diameterCap")
                    record.setValue(sourceRecord.lengthBody, forKey: "lengthBody")
                    record.setValue(sourceRecord.lengthCap, forKey: "lengthCap")
                    record.setValue(sourceRecord.lengthClosed, forKey: "lengthClosed")
                    record.setValue(sourceRecord.weightBody, forKey: "weightBody")
                    record.setValue(sourceRecord.weightCap, forKey: "weightCap")
                    record.setValue(sourceRecord.weightTotal, forKey: "weightTotal")
                    
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
