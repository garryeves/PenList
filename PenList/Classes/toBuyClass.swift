//
//  toBuyClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

struct groupedToBuys: Identifiable {
    let id = UUID()
    
    var type = ""
    var toBuys: [manuFacturerToBuys] = Array()
}

struct manuFacturerToBuys: Identifiable {
    let id = UUID()
    
    var manufacturer = ""
    var toBuys: [toBuy] = Array()
}

class toBuys: NSObject {
    fileprivate var myToBuys: [toBuy] = Array()
    fileprivate var myGroupedToBuys: [groupedToBuys] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getToBuy() {
            let object = toBuy(passedbuyID: item.buyID,
                               passedcost: item.cost,
                               passedlinkID: item.linkID,
                               passedmanID: item.manID,
                               passednotes: item.notes,
                               passedname: item.name,
                               passedstatus: item.status,
                               passedtype: item.type,
                               passedwhereFrom: item.whereFrom)
            
            myToBuys.append(object)
        }
        
        sortArrayByType()
    }
    
    func append(_ newItem: toBuy){
        myToBuys.append(newItem)
    }

    func sortArrayByType() {
        if myToBuys.count > 1 {
            myToBuys.sort {
                if $0.type == $1.type {
                    if $0.manufacturer == $1.manufacturer {
                        return $0.name < $1.name
                    } else {
                        return $0.manufacturer < $1.manufacturer
                    }
                } else {
                    return $0.type < $1.type
                }
            }
        }
        
        // Now we have the data sorted we need to do the grouping
        
        var workingType = ""
        var workingManufacturer = ""
        
        myGroupedToBuys.removeAll()
        
        var workingGroup: [toBuy] = Array()
        var workingMans: [manuFacturerToBuys] = Array()
        
        for item in myToBuys {
            if item.manufacturer != workingManufacturer {
                if workingGroup.count > 0 {
                    let tempMan = manuFacturerToBuys(manufacturer: workingManufacturer, toBuys: workingGroup)
                    workingMans.append(tempMan)
                    workingGroup.removeAll()
                }
                workingManufacturer = item.manufacturer
            }
            
            if item.type != workingType {
                if workingMans.count > 0 {
                    if workingGroup.count > 0 {
                        let tempMan = manuFacturerToBuys(manufacturer: workingManufacturer, toBuys: workingGroup)
                        workingMans.append(tempMan)
                        workingGroup.removeAll()
                    }
                }
                let tempitem = groupedToBuys(type: workingType, toBuys: workingMans)
                myGroupedToBuys.append(tempitem)
                
                workingGroup.removeAll()
                workingType = item.type
                workingMans.removeAll()
                workingManufacturer = item.manufacturer
            }
            workingGroup.append(item)
        }
        
        if workingGroup.count > 0 {
            let tempMan = manuFacturerToBuys(manufacturer: workingManufacturer, toBuys: workingGroup)
            workingMans.append(tempMan)
            let tempitem = groupedToBuys(type: workingType, toBuys: workingMans)
            myGroupedToBuys.append(tempitem)
        }
    }
    
    var toBuyGroup: [groupedToBuys] {
        get {
            return myGroupedToBuys
        }
    }
    
    var toBuyList: [toBuy] {
        get {
            return myToBuys
        }
    }
}

class toBuy: NSObject, Identifiable, ObservableObject {
    var buyID = UUID()
    
    fileprivate var price = 0.0
    
    var cost: String {
        get {
            if price == 0.0 {
                return("")
            }
            
            return price.formatCurrency
        }
        set {
            
            if newValue.isDouble() {
                price = Double(newValue)!
            } else {
                let working = newValue.formatCurrencyNoSign
                if working != -1.0 {
                    price = working
                }
            }
        }
    }
    
    var linkID = ""
    var manID = ""
    @Published var name = ""
    var notes = ""
    @Published var status = toBuyStatusPlanned
    var type = ""
    var whereFrom = ""

    var isNew = true

    var manufacturer: String {
        get {
            for item in manufacturerList.manufacturers {
                if item.manID.uuidString == manID {
                    return item.name
                }
            }
            
            return "No Manufacturer"
        }
        set {
            for item in manufacturerList.manufacturers {
                if item.name == newValue {
                    manID = item.manID.uuidString
                }
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    init(passedbuyID: String,
         passedcost: String,
         passedlinkID: String,
         passedmanID: String,
         passednotes: String,
         passedname: String,
         passedstatus: String,
         passedtype: String,
         passedwhereFrom: String) {
        super.init()
        buyID = UUID(uuidString: passedbuyID)!
        cost = passedcost
        linkID = passedlinkID
        manID = passedmanID
        notes = passednotes
        name = passedname
        status = passedstatus
        type = passedtype
        whereFrom = passedwhereFrom
        
        isNew = false
    }

    func save()
    {
        let temp = ToBuy(buyID: buyID.uuidString,
                         cost: cost,
                         linkID: linkID,
                         manID: manID,
                         name: name,
                         notes: notes,
                         status: status,
                         type: type,
                         whereFrom: whereFrom)
            
        myCloudDB.saveToBuy(temp)
    }
    
    func delete() {
        // delete the item
        myCloudDB.delete(buyID.uuidString)
    }
}

struct ToBuy {
    public var buyID: String
    public var cost: String
    public var linkID: String
    public var manID: String
    public var name: String
    public var notes: String
    public var status: String
    public var type: String
    public var whereFrom: String
}

extension CloudKitInteraction {
    private func populateToBuy(_ records: [CKRecord]) -> [ToBuy] {
        var tempArray: [ToBuy] = Array()
        
        for record in records {
            let tempItem = ToBuy(buyID: decodeString(record.object(forKey: "buyID")),
                                 cost: decodeString(record.object(forKey: "cost")),
                                 linkID: decodeString(record.object(forKey: "linkID")),
                                 manID: decodeString(record.object(forKey: "manID")),
                                 name: decodeString(record.object(forKey: "name")),
                                 notes: decodeString(record.object(forKey: "notes")),
                                 status: decodeString(record.object(forKey: "status")),
                                 type: decodeString(record.object(forKey: "type")),
                                 whereFrom: decodeString(record.object(forKey: "whereFrom")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getToBuy()->[ToBuy] {
        let predicate = NSPredicate(format: "status != \"\(toBuyStatusBought)\"")

        let query = CKQuery(recordType: "toBuy", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateToBuy(returnArray)
    }

    func delete(_ buyID: String) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "buyID == \"\(buyID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "toBuy", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPrivateDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveToBuy(_ sourceRecord: ToBuy) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "buyID == \"\(sourceRecord.buyID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "toBuy", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.cost, forKey: "cost")
                    record!.setValue(sourceRecord.linkID, forKey: "linkID")
                    record!.setValue(sourceRecord.manID, forKey: "manID")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.notes, forKey: "notes")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    record!.setValue(sourceRecord.whereFrom, forKey: "whereFrom")

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
                    let record = CKRecord(recordType: "toBuy")
                    record.setValue(sourceRecord.buyID, forKey: "buyID")
                    record.setValue(sourceRecord.cost, forKey: "cost")
                    record.setValue(sourceRecord.linkID, forKey: "linkID")
                    record.setValue(sourceRecord.manID, forKey: "manID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.type, forKey: "type")
                    record.setValue(sourceRecord.whereFrom, forKey: "whereFrom")

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

