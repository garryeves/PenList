//
//  myInkClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class myInks: NSObject {
    fileprivate var myInkList: [myInk] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getMyInk() {
            let object = myInk(passedamountPaid: item.amountPaid,
                               passedboughtFrom: item.boughtFrom,
                               passeddateBought: item.dateBought,
                               passedfinished: item.finished,
                               passedinkID: item.inkID,
                               passednotes: item.notes,
                               passedmyInkID: item.myInkID)
            myInkList.append(object)
        }
        
        sortArrayByName()
    }
    
    func append(_ newItem: myInk){
        myInkList.append(newItem)
    }

    func sortArrayByName() {
        if myInkList.count > 1 {
            myInkList.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var inks: [myInk] {
        get {
            return myInkList
        }
    }
}

class myInk: NSObject, Identifiable, ObservableObject {
    var myInkID = UUID()
    private var amountPaid: Double = 0.0
    var boughtFrom = ""
    var dateBought = Date()
    var finished = false
    var inkID = ""
    var notes = ""
    var isNew = true
    var photoList: myPenPhotos?

    var cost: String {
        get {
            return amountPaid.formatCurrency
        }
        set {
            if newValue.isDouble() {
                amountPaid = Double(newValue)!
            } else {
                let working = newValue.formatCurrencyNoSign
                if working != -1.0 {
                    amountPaid = working
                }
            }
        }
    }
    
//    var manufacturer: String {
//        get {
//            for item in inkList.inks {
//                if item.inkID.uuidString == inkID {
//                    return item.manufacturer
//                }
//            }
//            return "Unknown"
//        }
//    }
    var manufacturer: String {
        get {
            for item in inkList.inks {
                if item.inkID.uuidString == inkID {
                    return item.manufacturer
                }
            }
            
            return ""
        }
        set {
            for item in manufacturerList.manufacturers {
                if item.name == newValue {
                    for workingInk in inkList.inks {
                        if workingInk.inkID.uuidString == inkID {
                            workingInk.manID = item.manID.uuidString
                        }
                    }
                }
            }
        }
    }
    
    var inkFamily: String {
        for item in inkList.inks {
            if item.inkID.uuidString == inkID {
                return item.inkFamily
            }
        }
        return ""
    }
    
    var name: String {
        get {
            for item in inkList.inks {
                if item.inkID.uuidString == inkID {
                    return item.name
                }
            }
            return ""
        }
    }
    
    var images: myPenPhotos {
        get {
            if photoList == nil {
                photoList = myPenPhotos(penID: myInkID.uuidString)
            }
            return photoList!
        }
    }
    
    override init() {
        super.init()
    }
    
    init(passedamountPaid: Double,
         passedboughtFrom: String,
         passeddateBought: Date,
         passedfinished: Bool,
         passedinkID: String,
         passednotes: String,
         passedmyInkID: String) {
        super.init()
        amountPaid = passedamountPaid
        boughtFrom = passedboughtFrom
        dateBought = passeddateBought
        finished = passedfinished
        inkID = passedinkID
        notes = passednotes
        isNew = false
        myInkID = UUID(uuidString: passedmyInkID)!
    }
    
    init(passedinkID: String,
         passednotes: String) {
        super.init()
        dateBought = Date()
        inkID = passedinkID
        notes = passednotes
        isNew = false

        save()
    }

    func save()
    {
        let temp = MyInk(amountPaid: amountPaid,
                         boughtFrom: boughtFrom,
                         dateBought: dateBought,
                         finished: finished,
                         inkID: inkID,
                         notes: notes,
                         myInkID: myInkID.uuidString)
            
        myCloudDB.saveMyInk(temp)
    }
}

struct MyInk {
    public var amountPaid: Double
    public var boughtFrom: String
    public var dateBought: Date
    public var finished: Bool
    public var inkID: String
    public var notes: String
    public var myInkID: String
}

extension CloudKitInteraction {
    private func populateMyInk(_ records: [CKRecord]) -> [MyInk] {
        var tempArray: [MyInk] = Array()
        
        for record in records {
            let tempItem = MyInk(amountPaid: decodeDouble(record.object(forKey: "amountPaid")),
                                 boughtFrom: decodeString(record.object(forKey: "boughtFrom")),
                                 dateBought: decodeDate(record.object(forKey: "dateBought")),
                                 finished: decodeBool(record.object(forKey: "finished"), defaultReturn: false),
                                 inkID: decodeString(record.object(forKey: "inkID")),
                                 notes: decodeString(record.object(forKey: "notes")),
                                 myInkID: decodeString(record.object(forKey: "myInkID"))
            )
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getMyInk()->[MyInk] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "myInk", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateMyInk(returnArray)
    }

    func saveMyInk(_ sourceRecord: MyInk) {
        let finishedFlag = encodeBool(sourceRecord.finished)
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "myInkID == \"\(sourceRecord.myInkID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "myInk", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.amountPaid, forKey: "amountPaid")
                    record!.setValue(sourceRecord.boughtFrom, forKey: "boughtFrom")
                    record!.setValue(sourceRecord.dateBought, forKey: "dateBought")
                    record!.setValue(finishedFlag, forKey: "finished")
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
                    let record = CKRecord(recordType: "myInk")
                    
                    record.setValue(sourceRecord.amountPaid, forKey: "amountPaid")
                    record.setValue(sourceRecord.boughtFrom, forKey: "boughtFrom")
                    record.setValue(sourceRecord.dateBought, forKey: "dateBought")
                    record.setValue(finishedFlag, forKey: "finished")
                    record.setValue(sourceRecord.inkID, forKey: "inkID")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.myInkID, forKey: "myInkID")
                    
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

