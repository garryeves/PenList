//
//  myNotePads.swift
//  PenList
//
//  Created by Garry Eves on 11/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class myNotepads: NSObject {
    fileprivate var myNotepadList: [myNotepad] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        getData()

    }
    
    init(manID: String) {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getMyNotepads(manID) {
            let object = myNotepad(passedpricePaid: item.pricePaid,
                                   passedboughtFrom: item.boughtFrom,
                                   passeddateBought: item.dateBought,
                                   passedstartedUsing: item.startedUsing,
                                   passedfinishedUsing: item.finishedUsing,
                                   passednotepadID: item.notepadID,
                                   passednotes: item.notes,
                                   passedmyNotepadID: item.myNotepadID)
            myNotepadList.append(object)
        }
        
        sortArrayByName()
    }
    
    private func getData() {
        for item in myCloudDB.getMyNotepads() {
            let object = myNotepad(passedpricePaid: item.pricePaid,
                                   passedboughtFrom: item.boughtFrom,
                                   passeddateBought: item.dateBought,
                                   passedstartedUsing: item.startedUsing,
                                   passedfinishedUsing: item.finishedUsing,
                                   passednotepadID: item.notepadID,
                                   passednotes: item.notes,
                                   passedmyNotepadID: item.myNotepadID)
            myNotepadList.append(object)
        }
        
        sortArrayByName()
    }
    
    func reload() {
        myNotepadList.removeAll()
        
        getData()
    }
    
    func append(_ newItem: myNotepad){
        myNotepadList.append(newItem)
    }

    func sortArrayByName() {
        if myNotepadList.count > 1 {
            myNotepadList.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var notepads: [myNotepad] {
        get {
            return myNotepadList
        }
    }
    
    var activeNotepads: [myNotepad] {
        get {
            var tempArray: [myNotepad] = Array()
            
            if myNotepadList.count == 0 {
                return []
            } else {
                for item in myNotepadList {
                    if item.finishedUsing == nil {
                        tempArray.append(item)
                    }
                }
            }
            return tempArray
        }
    }
}

class myNotepad: NSObject, Identifiable, ObservableObject {
    var myNotepadID = UUID()
    private var pricePaid: Double = 0.0
    var boughtFrom = ""
    var dateBought = Date()
    var startedUsing: Date?
    var finishedUsing: Date?
    var notepadID = ""
    var notes = ""
    var isNew = true
//    var photoList: myPenPhotos?

    var cost: String {
        get {
            return pricePaid.formatCurrency
        }
        set {
            if newValue.isDouble() {
                pricePaid = Double(newValue)!
            } else {
                let working = newValue.formatCurrencyNoSign
                if working != -1.0 {
                    pricePaid = working
                }
            }
        }
    }
    
    var manufacturer: String {
        get {
            for item in notepadList.notepads {
                if item.notepadID.uuidString == notepadID {
                    return item.manufacturer
                }
            }
            
            return ""
        }
        set {
            for item in manufacturerList.manufacturers {
                if item.name == newValue {
                    for workingInk in notepadList.notepads {
                        if workingInk.notepadID.uuidString == notepadID {
                            workingInk.manID = item.manID.uuidString
                        }
                    }
                }
            }
        }
    }
    
    var name: String {
        get {
            for item in notepadList.notepads {
                if item.notepadID.uuidString == notepadID {
                    return item.name
                }
            }
            return ""
        }
    }
    
    
//    var images: myPenPhotos {
//        get {
//            if photoList == nil {
//                photoList = myPenPhotos(penID: myInkID.uuidString)
//            }
//            return photoList!
//        }
//    }
    
    override init() {
        super.init()
    }
    
    init(passedpricePaid: Double,
         passedboughtFrom: String,
         passeddateBought: Date,
         passedstartedUsing: Date?,
         passedfinishedUsing: Date?,
         passednotepadID: String,
         passednotes: String,
         passedmyNotepadID: String) {
        super.init()
         
        pricePaid = passedpricePaid
        boughtFrom = passedboughtFrom
        dateBought = passeddateBought
        startedUsing = passedstartedUsing
        finishedUsing = passedfinishedUsing
        notepadID = passednotepadID
        notes = passednotes
        isNew = false
        myNotepadID = UUID(uuidString: passedmyNotepadID)!
    }
    
    init(passednotepadID: String,
         passednotes: String) {
        super.init()
        dateBought = Date()
        notepadID = passednotepadID
        notes = passednotes
        isNew = false

        save()
    }

    func save() {
        let temp = MyNotepads(pricePaid: pricePaid,
                              boughtFrom: boughtFrom,
                              dateBought: dateBought,
                              startedUsing: startedUsing,
                              finishedUsing: finishedUsing,
                              notepadID: notepadID,
                              notes: notes,
                              myNotepadID: myNotepadID.uuidString)
            
        myCloudDB.saveMyNotepad(temp)
    }
}

struct MyNotepads {
    public var pricePaid: Double
    public var boughtFrom: String
    public var dateBought: Date
    public var startedUsing: Date?
    public var finishedUsing: Date?
    public var notepadID: String
    public var notes: String
    public var myNotepadID: String
}

extension CloudKitInteraction {
    private func populateMyNotepad(_ records: [CKRecord]) -> [MyNotepads] {
        var tempArray: [MyNotepads] = Array()
        
        for record in records {
            var tempStart: Date?
            if record.object(forKey: "startedUsing") != nil {
                tempStart = decodeDate(record.object(forKey: "startedUsing"))
            }
            
            var tempEnd: Date?
            if record.object(forKey: "finishedUsing") != nil {
                tempEnd = decodeDate(record.object(forKey: "finishedUsing"))
            }
            
            let tempItem = MyNotepads(pricePaid: decodeDouble(record.object(forKey: "pricePaid")),
                                      boughtFrom: decodeString(record.object(forKey: "boughtFrom")),
                                      dateBought: decodeDate(record.object(forKey: "dateBought")),
                                      startedUsing: tempStart,
                                      finishedUsing: tempEnd,
                                      notepadID: decodeString(record.object(forKey: "notepadID")),
                                      notes: decodeString(record.object(forKey: "notes")),
                                      myNotepadID: decodeString(record.object(forKey: "myNotepadID"))
            )
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getMyNotepads()->[MyNotepads] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let query = CKQuery(recordType: "myNotesPads", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateMyNotepad(returnArray)
    }
    
    func getMyNotepads(_ manID: String)->[MyNotepads] {
        let predicate = NSPredicate(format: "manID == \"\(manID)\"") // better be accurate to get only the record you need

        let query = CKQuery(recordType: "myNotesPads", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateMyNotepad(returnArray)
    }
    
    func saveMyNotepad(_ sourceRecord: MyNotepads) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "myNotepadID == \"\(sourceRecord.myNotepadID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "myNotesPads", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.pricePaid, forKey: "pricePaid")
                    record!.setValue(sourceRecord.boughtFrom, forKey: "boughtFrom")
                    record!.setValue(sourceRecord.dateBought, forKey: "dateBought")
                    record!.setValue(sourceRecord.startedUsing, forKey: "startedUsing")
                    record!.setValue(sourceRecord.finishedUsing, forKey: "finishedUsing")
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
                    let record = CKRecord(recordType: "myNotesPads")

                    record.setValue(sourceRecord.pricePaid, forKey: "pricePaid")
                    record.setValue(sourceRecord.boughtFrom, forKey: "boughtFrom")
                    record.setValue(sourceRecord.dateBought, forKey: "dateBought")
                    record.setValue(sourceRecord.startedUsing, forKey: "startedUsing")
                    record.setValue(sourceRecord.finishedUsing, forKey: "finishedUsing")
                    record.setValue(sourceRecord.notepadID, forKey: "notepadID")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.myNotepadID, forKey: "myNotepadID")
                    
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

