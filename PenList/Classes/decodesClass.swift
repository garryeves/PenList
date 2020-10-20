//
//  decodesClass.swift
//  PenList
//
//  Created by Garry Eves on 8/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class decodes: NSObject {
    fileprivate var myDecodeList: [decode] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getDecodes() {
            let object = decode(passeddecodeID: item.decodeID,
                                passeddecodeDescription: item.decodeDescription,
                                passeddecodeOrder: item.decodeOrder,
                                passeddecodeType: item.decodeType)
            
            myDecodeList.append(object)
        }
        
        sortArray()
    }

    private func sortArray() {
        if myDecodeList.count > 1 {
            myDecodeList.sort {
                if $0.decodeOrder == $1.decodeOrder {
                    return $0.decodeDescription < $1.decodeDescription
                } else {
                    return $0.decodeOrder < $1.decodeOrder
                }
            }
        }
    }

    func decodes(_ decodeType: String) -> [decode] {
        return myDecodeList.filter { $0.decodeType == decodeType }
    }
    
    func decodesText(_ decodeType: String) -> [String] {
        var temp: [String] = Array()
        
        let tempList = myDecodeList.filter { $0.decodeType == decodeType }
        
        for item in tempList {
            temp.append(item.decodeDescription)
        }
        
        return temp
    }
}

class decode: NSObject, Identifiable, ObservableObject {
    var decodeID = UUID()
    var decodeDescription = ""
    var decodeOrder: Int64 = 0
    var decodeType = ""
    
    override init() {
        super.init()
    }
    
    init(passeddecodeID: String,
         passeddecodeDescription: String,
         passeddecodeOrder: Int64,
         passeddecodeType: String) {
        super.init()
        decodeID = UUID(uuidString: passeddecodeID)!
        decodeDescription = passeddecodeDescription
        decodeOrder = passeddecodeOrder
        decodeType = passeddecodeType
    }
    
    init(passeddecodeDescription: String,
         passeddecodeOrder: Int64,
         passeddecodeType: String) {

        super.init()
        
        decodeDescription = passeddecodeDescription
        decodeOrder = passeddecodeOrder
        decodeType = passeddecodeType

        save()
    }

    func save()
    {
        let temp = Decodes(decodeDescription: decodeDescription,
                           decodeID: decodeID.uuidString,
                           decodeOrder: decodeOrder,
                           decodeType: decodeType)
            
        myCloudDB.saveDecodes(temp)
    }
}

struct Decodes {
    public var decodeDescription: String
    public var decodeID: String
    public var decodeOrder: Int64
    public var decodeType: String
}

extension CloudKitInteraction {
    private func populateDecodes(_ records: [CKRecord]) -> [Decodes] {
        var tempArray: [Decodes] = Array()
        
        for record in records {
            let tempItem = Decodes(decodeDescription: decodeString(record.object(forKey: "description")),
                               decodeID: decodeString(record.object(forKey: "ID")),
                               decodeOrder: decodeInt64(record.object(forKey: "order")),
                               decodeType: decodeString(record.object(forKey: "type")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getDecodes()->[Decodes] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "decodes", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateDecodes(returnArray)
    }

    func saveDecodes(_ sourceRecord: Decodes) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "ID == \"\(sourceRecord.decodeID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "decodes", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.decodeDescription, forKey: "description")
                    record!.setValue(sourceRecord.decodeOrder, forKey: "order")
                    record!.setValue(sourceRecord.decodeType, forKey: "type")

                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    let record = CKRecord(recordType: "decodes")
                    record.setValue(sourceRecord.decodeID, forKey: "ID")
                    record.setValue(sourceRecord.decodeDescription, forKey: "description")
                    record.setValue(sourceRecord.decodeOrder, forKey: "order")
                    record.setValue(sourceRecord.decodeType, forKey: "type")

                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
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
